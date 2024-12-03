page 50101 "Item Prices Overview"
{
    Caption = 'Prices Overview';
    DataCaptionExpression = PageCaptionText;
    DelayedInsert = true;
    PageType = Worksheet;
    SaveValues = true;
    RefreshOnActivate = true;
    SourceTable = "Price List Line";
    ApplicationArea = Basic, Suite;
    UsageCategory = Tasks;

    layout
    {
        area(content)
        {
            group(General)
            {
                Caption = 'General';
                field(PriceType; PriceSource."Price Type")
                {
                    Caption = 'Price Type Filter';
                    ToolTip = 'Specifies a filter for which prices to display: sale, purchase or both.';
                    trigger OnValidate()
                    begin
                        PriceSource.Validate("Price Type");
                        SetRecFilters();
                    end;
                }
                group(SourceFilters)
                {
                    ShowCaption = false;
                    field(SourceType; PriceSource."Source Type")
                    {
                        Caption = 'Assign-to Type Filter';
                        ToolTip = 'Specifies a filter for which prices to display.';

                        trigger OnValidate()
                        begin
                            PriceSource.Validate("Source Type");
                            ParentSourceNoFilter := '';
                            SourceNoFilter := '';
                            SetRecFilters();
                        end;
                    }
                    field(ParentSourceNo; ParentSourceNoFilter)
                    {
                        Caption = 'Assign-to Parent No. Filter';
                        Visible = ParentSourceNoFilterEditable;
                        ToolTip = 'Specifies a filter for which prices to display.';

                        trigger OnLookup(var Text: Text): Boolean
                        var
                            JobPriceSource: Record "Price Source";
                        begin
                            if not PriceSource.IsParentSourceAllowed() then
                                exit;
                            JobPriceSource."Source Group" := JobPriceSource."Source Group"::Job;
                            JobPriceSource."Source Type" := "Price Source Type"::Job;
                            if JobPriceSource.LookupNo() then begin
                                ParentSourceNoFilter := JobPriceSource."Source No.";
                                SourceNoFilter := '';
                            end;
                        end;

                        trigger OnValidate()
                        begin
                            PriceSource.Validate("Parent Source No.");
                        end;
                    }
                    field(SourceNo; SourceNoFilter)
                    {
                        Caption = 'Assign-to Filter';
                        Enabled = SourceNoFilterEditable;
                        ToolTip = 'Specifies a filter for which prices to display.';

                        trigger OnLookup(var Text: Text): Boolean
                        begin
                            if PriceSource.LookupNo() then begin
                                Text := PriceSource."Source No.";
                                exit(true);
                            end;
                        end;

                        trigger OnValidate()
                        begin
                            SetRecFilters();
                        end;
                    }
                }
                field(ItemNo; ItemNoFilter)
                {
                    Caption = 'Item No. Filter';
                    ToolTip = 'Specifies a filter for which prices to display.';

                    trigger OnLookup(var Text: Text): Boolean
                    begin
                        PriceAsset."Asset Type" := PriceAsset."Asset Type"::Item;
                        if PriceAsset.LookupNo() then begin
                            Text := PriceAsset."Asset No.";
                            exit(true);
                        end;
                    end;

                    trigger OnValidate()
                    begin
                        SetRecFilters();
                    end;
                }
                field(AmountType; AmountTypeFilter)
                {
                    Caption = 'Defines Filter';
                    ToolTip = 'Specifies whether the price list line defines prices, discounts, or both.';

                    trigger OnValidate()
                    begin
                        SetRecFilters();
                    end;
                }
                group(DateFilters)
                {
                    ShowCaption = false;
                    field(StartingDateFilter; StartingDateFilter)
                    {
                        Caption = 'Starting Date Filter';
                        ToolTip = 'Specifies a filter for which prices to display.';

                        trigger OnValidate()
                        var
                            FilterTokens: Codeunit "Filter Tokens";
                        begin
                            FilterTokens.MakeDateFilter(StartingDateFilter);
                            SetRecFilters();
                        end;
                    }
                    field(EndingDateFilter; EndingDateFilter)
                    {
                        Caption = 'Ending Date Filter';
                        ToolTip = 'Specifies a filter for which prices to display.';

                        trigger OnValidate()
                        var
                            FilterTokens: Codeunit "Filter Tokens";
                        begin
                            FilterTokens.MakeDateFilter(EndingDateFilter);
                            SetRecFilters();
                        end;
                    }
                }
                field(CurrencyCodeFilterCtrl; CurrencyCodeFilter)
                {
                    Caption = 'Currency Code Filter';
                    ToolTip = 'Specifies a filter for which prices to display.';

                    trigger OnLookup(var Text: Text): Boolean
                    var
                        CurrencyList: Page Currencies;
                    begin
                        CurrencyList.LookupMode := true;
                        if CurrencyList.RunModal() = ACTION::LookupOK then
                            Text := CurrencyList.GetSelectionFilter()
                        else
                            exit(false);

                        exit(true);
                    end;

                    trigger OnValidate()
                    begin
                        SetRecFilters();
                    end;
                }
            }
            repeater(Lines)
            {
                ShowCaption = false;
                field("Price List Code"; Rec."Price List Code")
                {
                    Editable = PriceListCodeEditable;
                    Style = Attention;
                    StyleExpr = LineToVerify;
                    ToolTip = 'Specifies the unique identifier of the price list.';

                    trigger OnDrillDown()
                    begin
                        PriceUXManagement.EditPriceList(Rec."Price List Code");
                    end;
                }
                field(Status; Rec.Status)
                {
                    Editable = false;
                    Style = Attention;
                    StyleExpr = LineToVerify;
                    ToolTip = 'Specifies whether the price list line is in Draft status and can be edited, Inactive and cannot be edited or used, or Active and used for price calculations.';
                }
                field("Price Type"; Rec."Price Type")
                {
                    Visible = PriceTypeVisible;
                    Editable = PriceListCodeEditable and AllowUpdatingDefaults;
                    ValuesAllowed = Sale, Purchase;
                    ToolTip = 'Specifies the price type: sale or purchase price.';
                    trigger OnValidate()
                    begin
                        if Rec."Price Type" = Rec."Price Type"::Sale then
                            Rec."Source Type" := Rec."Source Type"::"All Customers"
                        else
                            Rec."Source Type" := Rec."Source Type"::"All Vendors";
                        SetDefaultPriceListCode();
                    end;
                }
                field("Source Type"; Rec."Source Type")
                {
                    Editable = PriceListCodeEditable and SourceTypeEditable;
                    ValuesAllowed = "All Customers", Customer, "Customer Price Group", "Customer Disc. Group", "All Vendors", Vendor, "All Jobs", Job, "Job Task", Campaign, Contact;
                    ToolTip = 'Specifies the source of the price on the price list line. For example, the price can come from the customer or customer price group.';

                    trigger OnValidate()
                    begin
                        case Rec."Source Type" of
                            Rec."Source Type"::"All Customers",
                            Rec."Source Type"::Customer,
                            Rec."Source Type"::"Customer Price Group",
                            Rec."Source Type"::"Customer Disc. Group":
                                Rec."Price Type" := Rec."Price Type"::Sale;
                            Rec."Source Type"::"All Vendors",
                            Rec."Source Type"::Vendor:
                                Rec."Price Type" := Rec."Price Type"::Purchase;
                        end;
                        SetDefaultPriceListCode();
                        CalcSourceNoEditable()
                    end;
                }
                field("Assign-to Parent No."; Rec."Assign-to Parent No.")
                {
                    Editable = AssignToParentNoEditable;
                    ShowMandatory = AssignToParentNoEditable;
                    ToolTip = 'Specifies the unique identifier of the project on the price list line.';
                }
                field("Assign-to No."; Rec."Assign-to No.")
                {
                    Editable = AssignToNoEditable;
                    ShowMandatory = AssignToNoEditable;
                    ToolTip = 'Specifies the unique identifier of the source of the price on the price list line.';
                }
                field("Product No."; Rec."Product No.")
                {
                    Editable = PriceLineEditable;
                    ShowMandatory = PriceLineEditable;
                    Style = Attention;
                    StyleExpr = LineToVerify;
                    ToolTip = 'Specifies the number of the product.';
                }
                field("Variant Code Lookup"; Rec."Variant Code Lookup")
                {
                    Editable = VariantCodeEditable;
                    ToolTip = 'Specifies the variant of the item on the line.';
                }
                field("Currency Code"; Rec."Currency Code")
                {
                    Editable = DateEditable;
                    ToolTip = 'Specifies the currency code of the price list line.';
                }
                field("Unit of Measure Code Lookup"; Rec."Unit of Measure Code Lookup")
                {
                    Editable = PriceLineEditable;
                    ToolTip = 'Specifies the unit price of the product.';
                }
                field("Minimum Quantity"; Rec."Minimum Quantity")
                {
                    Editable = PriceLineEditable;
                    ToolTip = 'Specifies the minimum quantity of the product.';
                }
                field("Amount Type"; Rec."Amount Type")
                {
                    Visible = AmountTypeIsVisible;
                    Editable = AmountTypeIsEditable;
                    ToolTip = 'Specifies whether the price list line defines prices, discounts, or both.';
                }
                field("Unit Price"; Rec."Unit Price")
                {
                    Visible = SalesPriceVisible;
                    Editable = UnitPriceEditable;
                    Style = Attention;
                    StyleExpr = LineToVerify and SalesPriceLine and PriceEditable;
                    ToolTip = 'Specifies the unit price of the product.';
                }
                field("Direct Unit Cost"; Rec."Direct Unit Cost")
                {
                    Visible = PurchPriceVisible;
                    Editable = UnitPriceEditable;
                    Style = Attention;
                    StyleExpr = LineToVerify and PurchPriceLine and PriceEditable;
                    ToolTip = 'Specifies the direct unit cost of the product.';
                }
                field("Unit Cost"; Rec."Unit Cost")
                {
                    Visible = PurchPriceVisible;
                    Editable = UnitPriceEditable;
                    Style = Attention;
                    StyleExpr = LineToVerify and PurchPriceLine and PriceEditable;
                    ToolTip = 'Specifies the unit cost of the resource.';
                }
                field("Line Discount %"; Rec."Line Discount %")
                {
                    Visible = DiscountVisible;
                    Editable = LineDiscPctEditable;
                    Style = Attention;
                    StyleExpr = LineToVerify and DiscountEditable;
                    ToolTip = 'Specifies the line discount percentage for the product.';
                }
                field("Starting Date"; Rec."Starting Date")
                {
                    Editable = DateEditable;
                    ToolTip = 'Specifies the date from which the price is valid.';
                }
                field("Ending Date"; Rec."Ending Date")
                {
                    Editable = DateEditable;
                    ToolTip = 'Specifies the last date that the price is valid.';
                }
                field("Allow Line Disc."; Rec."Allow Line Disc.")
                {
                    Visible = AllowDiscVisible;
                    Editable = PriceLineEditable;
                    ToolTip = 'Specifies if a line discount will be calculated when the price is offered.';
                }
                field("Allow Invoice Disc."; Rec."Allow Invoice Disc.")
                {
                    Visible = AllowDiscVisible;
                    Editable = PriceLineEditable;
                    ToolTip = 'Specifies if an invoice discount will be calculated when the price is offered.';
                }
                field("VAT Bus. Posting Gr. (Price)"; Rec."VAT Bus. Posting Gr. (Price)")
                {
                    Visible = false;
                    Editable = PriceLineEditable;
                    ToolTip = 'Specifies the VAT business posting group for customers for whom you want the price (which includes VAT) to apply.';
                }
                field("Price Includes VAT"; Rec."Price Includes VAT")
                {
                    Visible = false;
                    Editable = PriceLineEditable;
                    ToolTip = 'Specifies if the price includes VAT.';
                }
            }
        }
    }

    actions
    {
        area(Navigation)
        {
            action(OpenPriceList)
            {
                Caption = 'Open Price List';
                Image = EditLines;
                Visible = LineExists;
                ToolTip = 'View or edit the price list.';

                trigger OnAction()
                begin
                    PriceUXManagement.EditPriceList(Rec."Price List Code");
                end;
            }

        }
        area(processing)
        {
            group("F&unctions")
            {
                Caption = 'F&unctions';
                Image = "Action";
                action(VerifyLines)
                {
                    Ellipsis = true;
                    Image = CheckDuplicates;
                    Caption = 'Verify Lines';
                    ToolTip = 'Checks data consistency in the new and modified price list lines. Finds the duplicate price lines and suggests the resolution of the line conflicts.';

                    trigger OnAction()
                    var
                        PriceListLine: Record "Price List Line";
                    begin
                        PriceListLine.Copy(Rec);
                        PriceListManagement.ActivateDraftLines(PriceListLine);
                        CurrPage.Update(false);
                    end;
                }
                action(ImportFromExcel)
                {
                    Caption = 'Import From Excel';
                    Image = ImportExcel;
                    ToolTip = 'Import prices from Excel.';

                    trigger OnAction()
                    var
                        ImportPricesfromExcel: Report "Import Prices from Excel";
                    begin
                        ImportPricesfromExcel.RunModal();
                    end;
                }
            }
        }
        area(Promoted)
        {
            group(Category_Process)
            {
                Caption = 'Process';

                actionref(VerifyLines_Promoted; VerifyLines)
                {
                }
                actionref(OpenPriceList_Promoted; OpenPriceList)
                {
                }
                actionref(ImportFromExcel_Promoted; ImportFromExcel)
                {
                }
            }
        }
    }

#if not CLEAN25
    trigger OnInit()
    var
        FeaturePriceCalculation: Codeunit "Feature - Price Calculation";
    begin
        FeaturePriceCalculation.FailIfFeatureDisabled();
    end;
#endif
    trigger OnAfterGetCurrRecord()
    begin
        SetEditableFields();
        LineExists := Rec."Price List Code" <> '';
    end;

    trigger OnAfterGetRecord()
    begin
        CalcSourceNoEditable();
        SetFieldsStyle();
    end;

    trigger OnOpenPage()
    begin
        OnBeforeOpenPage(PriceSource);

        GetRecFilters();
        SetRecFilters();
    end;

    trigger OnInsertRecord(BelowxRec: Boolean): Boolean
    begin
        Rec.SetNextLineNo();
        Rec.TestField("Price List Code");
    end;

    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        Rec."Price List Code" := PriceListManagement.GetDefaultPriceListCode(Rec."Price Type"::Sale, Rec."Source Group"::Customer, true);
        Rec."Asset Type" := Rec."Asset Type"::Item;
        if StrLen(ItemNoFilter) <= MaxStrLen(Item."No.") then
            if Item.Get(ItemNoFilter) then begin
                Rec.Validate("Asset No.", ItemNoFilter);
                Rec."Product No." := ItemNoFilter;
            end;
        Rec."Price Type" := Rec."Price Type"::Sale;
        Rec."Source Type" := Rec."Source Type"::"All Customers";
    end;

    var
        Item: Record Item;
        PriceSource: Record "Price Source";
        CurrPriceListHeader: Record "Price List Header";
        PriceListManagement: Codeunit "Price List Management";
        PriceUXManagement: Codeunit "Price UX Management";
        FilterRecordRef: RecordRef;
        AmountTypeFilter: Enum "Price Amount Type";
        ParentSourceNoEditable: Boolean;
        SourceTypeEditable: Boolean;
        SourceNoEditable: Boolean;
        ParentSourceNoFilter: Text;
        ParentSourceNoFilterEditable: Boolean;
        SourceNoFilter: Text;
        SourceNoFilterEditable: Boolean;
        CurrencyCodeFilter: Text;
        StartingDateFilter: Text;
        EndingDateFilter: Text;
        PageCaptionText: Text;
        WithinFilterLbl: Label 'No %1 within the filter %2.', Comment = '%1 - the unique entity id, %2 - the filter string ';
        AssignToNoEditable: Boolean;
        AssignToParentNoEditable: Boolean;
        PriceTypeVisible: Boolean;
        AmountTypeIsEditable: Boolean;
        AmountTypeIsVisible: Boolean;
        PriceVisible: Boolean;
        DiscountVisible: Boolean;
        SalesVisible: Boolean;
        PurchVisible: Boolean;
        PriceLineEditable: Boolean;
        DiscountEditable: Boolean;
        PriceEditable: Boolean;
        LineToVerify: Boolean;
        SalesPriceLine: Boolean;
        SalesPriceVisible: Boolean;
        PurchPriceLine: Boolean;
        PurchPriceVisible: Boolean;
        AllowDiscVisible: Boolean;
        AllowUpdatingDefaults: Boolean;
        DateEditable: Boolean;
        VariantCodeEditable: Boolean;
        UnitPriceEditable: Boolean;
        LineDiscPctEditable: Boolean;
        LineExists: Boolean;
        PriceListCodeEditable: Boolean;

    protected var
        PriceAsset: Record "Price Asset";
        ItemNoFilter: Text;

    procedure SetRecFilters()
    begin
        RefreshSourceNoFilter();
        SetFilters();
        CheckRecFilters();
        SetVisibleFields();

        CurrPage.Update(false);
    end;

    local procedure CalcSourceNoEditable()
    begin
        SourceNoEditable := Rec.IsSourceNoAllowed();
        ParentSourceNoEditable := PriceSource.IsParentSourceAllowed();
    end;

    local procedure CheckFilters(TableNo: Integer; FilterTxt: Text)
    var
        FilterFieldRef: FieldRef;
    begin
        if (FilterTxt = '') or (TableNo = 0) then
            exit;
        Clear(FilterFieldRef);
        if FilterRecordRef.Number <> TableNo then begin
            Clear(FilterRecordRef);
            FilterRecordRef.Open(TableNo);
        end;
        FilterFieldRef := FilterRecordRef.Field(1);
        FilterFieldRef.SetFilter(FilterTxt);
        if FilterRecordRef.IsEmpty() then
            Error(WithinFilterLbl, FilterRecordRef.Caption, FilterTxt);
    end;

    local procedure CheckRecFilters()
    begin
        case PriceSource."Source Type" of
            PriceSource."Source Type"::Customer:
                CheckFilters(Database::Customer, SourceNoFilter);
            PriceSource."Source Type"::"Customer Price Group":
                CheckFilters(Database::"Customer Price Group", SourceNoFilter);
            PriceSource."Source Type"::Campaign:
                CheckFilters(Database::Campaign, SourceNoFilter);
            PriceSource."Source Type"::Contact:
                CheckFilters(Database::Contact, SourceNoFilter);
        end;

        CheckFilters(PriceAsset."Table Id", ItemNoFilter);
        CheckFilters(Database::Currency, CurrencyCodeFilter);
    end;

    local procedure GetRecFilters()
    begin
        if Rec.GetFilters() <> '' then begin
            UpdateBasicRecFilters();
            Rec.Reset();
        end;

        Rec.FilterGroup(2);
        if Rec.GetFilters() <> '' then
            UpdateBasicRecFilters();

        Evaluate(StartingDateFilter, Rec.GetFilter("Starting Date"));
        Rec.FilterGroup(0);
    end;

    local procedure RefreshSourceNoFilter()
    begin
        SourceNoFilterEditable := PriceSource.IsSourceNoAllowed();
        ParentSourceNoFilterEditable := PriceSource.IsParentSourceAllowed();
        if not SourceNoFilterEditable then begin
            ParentSourceNoFilter := '';
            SourceNoFilter := '';
        end;
    end;

    local procedure SetEditableFields()
    begin
        PriceListCodeEditable := Rec."Line No." = 0;
        if Rec."Price List Code" <> CurrPriceListHeader.Code then begin
            AllowUpdatingDefaults := true;
            if CurrPriceListHeader.Get(Rec."Price List Code") then
                AllowUpdatingDefaults := CurrPriceListHeader."Allow Updating Defaults";
        end;

        PriceLineEditable := Rec.IsEditable();
        SourceTypeEditable :=
            (PriceSource."Source Type" = PriceSource."Source Type"::All) and PriceLineEditable and AllowUpdatingDefaults;
        AmountTypeIsEditable := PriceLineEditable;
        CalcSourceNoEditable();
        SetFieldsStyle();
        VariantCodeEditable := PriceLineEditable;
        UnitPriceEditable := PriceLineEditable and PriceEditable;
        DateEditable := PriceLineEditable and AllowUpdatingDefaults;
        LineDiscPctEditable := PriceLineEditable and DiscountEditable;
        AssignToNoEditable := SourceNoEditable and PriceLineEditable and AllowUpdatingDefaults;
        AssignToParentNoEditable := PriceLineEditable and ParentSourceNoEditable and AllowUpdatingDefaults;
    end;

    local procedure SetFieldsStyle()
    begin
        LineToVerify := Rec.IsLineToVerify();
        SalesPriceLine := Rec."Price Type" = Rec."Price Type"::Sale;
        PurchPriceLine := Rec."Price Type" = Rec."Price Type"::Purchase;
        PriceEditable := Rec."Amount Type" in [Rec."Amount Type"::Any, Rec."Amount Type"::Price];
        DiscountEditable := Rec."Amount Type" in [Rec."Amount Type"::Any, Rec."Amount Type"::Discount];
    end;

    local procedure SetFilters()
    begin
        Rec.FilterGroup(2);
        if PriceSource."Price Type" <> PriceSource."Price Type"::Any then
            Rec.SetRange("Price Type", PriceSource."Price Type")
        else
            Rec.SetRange("Price Type");

        if PriceSource."Source Type" <> PriceSource."Source Type"::All then
            Rec.SetRange("Source Type", PriceSource."Source Type")
        else
            Rec.SetRange("Source Type");

        if SourceNoFilter <> '' then
            Rec.SetFilter("Source No.", SourceNoFilter)
        else
            Rec.SetRange("Source No.");

        Rec.SetRange("Asset Type", Rec."Asset Type"::Item);

        if ItemNoFilter <> '' then
            Rec.SetFilter("Asset No.", ItemNoFilter)
        else
            Rec.SetRange("Asset No.");

        if AmountTypeFilter <> AmountTypeFilter::Any then
            Rec.SetRange("Amount Type", AmountTypeFilter)
        else
            Rec.SetRange("Amount Type");

        if CurrencyCodeFilter <> '' then
            Rec.SetFilter("Currency Code", CurrencyCodeFilter)
        else
            Rec.SetRange("Currency Code");

        if StartingDateFilter <> '' then
            Rec.SetFilter("Starting Date", StartingDateFilter)
        else
            Rec.SetRange("Starting Date");

        if EndingDateFilter <> '' then
            Rec.SetFilter("Ending Date", EndingDateFilter)
        else
            Rec.SetRange("Ending Date");
        Rec.FilterGroup(0);

        OnAfterSetFilters(Rec);
    end;

    local procedure SetVisibleFields()
    var
        PriceListLine: Record "Price List Line";
    begin
        PriceTypeVisible := PriceSource."Price Type" = PriceSource."Price Type"::Any;
        AmountTypeIsVisible := AmountTypeFilter = AmountTypeFilter::Any;
        PriceVisible := AmountTypeFilter in [AmountTypeFilter::Any, AmountTypeFilter::Price];
        DiscountVisible := AmountTypeFilter in [AmountTypeFilter::Any, AmountTypeFilter::Discount];
        SalesVisible := PriceSource."Price Type" in [PriceSource."Price Type"::Any, PriceSource."Price Type"::Sale];
        PurchVisible := PriceSource."Price Type" in [PriceSource."Price Type"::Any, PriceSource."Price Type"::Purchase];

        SalesPriceVisible := PriceVisible and SalesVisible;
        PurchPriceVisible := PriceVisible and PurchVisible;
        AllowDiscVisible := PriceVisible;
    end;

    local procedure UpdateBasicRecFilters()
    begin
        if Rec.GetFilter("Source Type") <> '' then
            Evaluate(PriceSource."Source Type", Rec.GetFilter("Source Type"))
        else
            PriceSource."Source Type" := PriceSource."Source Type"::All;

        SourceNoFilter := Rec.GetFilter("Source No.");
        ItemNoFilter := Rec.GetFilter("Asset No.");
        CurrencyCodeFilter := Rec.GetFilter("Currency Code");
    end;

    local procedure SetDefaultPriceListCode()
    begin
        if Rec."Price Type" = Rec."Price Type"::Sale then
            if Rec."Source Type" in [Rec."Source Type"::"All Jobs", Rec."Source Type"::Job, Rec."Source Type"::"Job Task"] then
                Rec."Price List Code" := PriceListManagement.GetDefaultPriceListCode(Rec."Price Type"::Sale, Rec."Source Group"::Job, true)
            else
                Rec."Price List Code" := PriceListManagement.GetDefaultPriceListCode(Rec."Price Type"::Sale, Rec."Source Group"::Customer, true)
        else
            if Rec."Source Type" in [Rec."Source Type"::"All Jobs", Rec."Source Type"::Job, Rec."Source Type"::"Job Task"] then
                Rec."Price List Code" := PriceListManagement.GetDefaultPriceListCode(Rec."Price Type"::Purchase, Rec."Source Group"::Job, true)
            else
                Rec."Price List Code" := PriceListManagement.GetDefaultPriceListCode(Rec."Price Type"::Purchase, Rec."Source Group"::Vendor, true);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterSetFilters(var PriceListLine: record "Price List Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeOpenPage(var PriceSource: record "Price Source")
    begin
    end;
}

