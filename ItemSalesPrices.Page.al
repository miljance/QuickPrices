namespace QuickPrices.QuickPrices;

using Microsoft.Sales.Pricing;
using Microsoft.CRM.Campaign;
using Microsoft.Finance.Currency;
using Microsoft.CRM.Contact;
using Microsoft.Inventory.Item;
using Microsoft.Sales.Customer;
using System.Text;
using System.Globalization;
using Microsoft.Pricing.PriceList;

page 50100 "Item Sales Prices"
{
    Caption = 'Item Sales Prices';
    DataCaptionExpression = PageCaptionText;
    DelayedInsert = true;
    PageType = List;
    SaveValues = true;
    SourceTable = "Price List Line";
    UsageCategory = Tasks;
    ApplicationArea = All;

    layout
    {
        area(content)
        {
            group(General)
            {
                Caption = 'General';
                field(SourceTypeFilter; SourceTypeFilter)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Sales Type Filter';
                    ToolTip = 'Specifies a filter for which sales prices to display.';

                    trigger OnValidate()
                    begin
                        SalesTypeFilterOnAfterValidate();
                    end;
                }
                field(SalesCodeFilterCtrl; SalesCodeFilter)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Sales Code Filter';
                    Enabled = SalesCodeFilterCtrlEnable;
                    ToolTip = 'Specifies a filter for which sales prices to display.';

                    trigger OnLookup(var Text: Text): Boolean
                    var
                        CustList: Page "Customer List";
                        CustPriceGrList: Page "Customer Price Groups";
                        CampaignList: Page "Campaign List";
                    begin
                        if SourceTypeFilter = SourceTypeFilter::"All Customers" then
                            exit;

                        case SourceTypeFilter of
                            SourceTypeFilter::Customer:
                                begin
                                    CustList.LookupMode := true;
                                    if CustList.RunModal() = ACTION::LookupOK then
                                        Text := CustList.GetSelectionFilter()
                                    else
                                        exit(false);
                                end;
                            SourceTypeFilter::"Customer Price Group":
                                begin
                                    CustPriceGrList.LookupMode := true;
                                    if CustPriceGrList.RunModal() = ACTION::LookupOK then
                                        Text := CustPriceGrList.GetSelectionFilter()
                                    else
                                        exit(false);
                                end;
                            SourceTypeFilter::Campaign:
                                begin
                                    CampaignList.LookupMode := true;
                                    if CampaignList.RunModal() = ACTION::LookupOK then
                                        Text := CampaignList.GetSelectionFilter()
                                    else
                                        exit(false);
                                end;
                        end;

                        exit(true);
                    end;

                    trigger OnValidate()
                    begin
                        SalesCodeFilterOnAfterValidate();
                    end;
                }
                field(ItemNoFilterCtrl; ItemNoFilter)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Item No. Filter';
                    ToolTip = 'Specifies a filter for which sales prices to display.';

                    trigger OnLookup(var Text: Text): Boolean
                    var
                        ItemList: Page "Item List";
                    begin
                        ItemList.LookupMode := true;
                        if ItemList.RunModal() = ACTION::LookupOK then
                            Text := ItemList.GetSelectionFilter()
                        else
                            exit(false);

                        exit(true);
                    end;

                    trigger OnValidate()
                    begin
                        ItemNoFilterOnAfterValidate();
                    end;
                }
                field(StartingDateFilter; StartingDateFilter)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Starting Date Filter';
                    ToolTip = 'Specifies a filter for which sales prices to display.';

                    trigger OnValidate()
                    var
                        FilterTokens: Codeunit "Filter Tokens";
                    begin
                        FilterTokens.MakeDateFilter(StartingDateFilter);
                        StartingDateFilterOnAfterValid();
                    end;
                }
                field(CurrencyCodeFilterCtrl; CurrencyCodeFilter)
                {
                    ApplicationArea = Suite;
                    Caption = 'Currency Code Filter';
                    ToolTip = 'Specifies a filter for which sales prices to display.';

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
                        CurrencyCodeFilterOnAfterValid();
                    end;
                }
            }
            repeater(Control1)
            {
                ShowCaption = false;
                field("Price List Code"; Rec."Price List Code")
                {
                    ApplicationArea = Basic, Suite;
                    Style = Attention;
                    StyleExpr = LineToVerify;
                    Editable = PriceListCodeEditable;
                    ToolTip = 'Specifies the unique identifier of the price list.';

                    trigger OnDrillDown()
                    begin
                        PriceUXManagement.EditPriceList(Rec."Price List Code");
                    end;
                }
                field(Status; Rec.Status)
                {
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                    Style = Attention;
                    StyleExpr = LineToVerify;
                    ToolTip = 'Specifies whether the price list line is in Draft status and can be edited, Inactive and cannot be edited or used, or Active and used for price calculations.';
                }
                field(SourceType; SourceType)
                {
                    ApplicationArea = All;
                    Caption = 'Assign-to Type';
                    ToolTip = 'Specifies the type of entity to which the price list is assigned. The options are relevant to the entity you are currently viewing.';

                    trigger OnValidate()
                    begin
                        ValidateSourceType(SourceType.AsInteger());
                    end;
                }
                field(AssignToNo; Rec."Assign-to No.")
                {
                    ApplicationArea = All;
                    Importance = Promoted;
                    Enabled = SourceNoEnabled;
                    ShowMandatory = SourceNoEnabled;
                    ToolTip = 'Specifies the entity to which the prices are assigned. The options depend on the selection in the Assign-to Type field. If you choose an entity, the price list will be used only for that entity.';
                }
                field(CurrencyCode; Rec."Currency Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the currency that is used for the prices on the price list. The currency can be the same for all prices on the price list, or you can specify a currency for individual lines.';
                    Visible = false;
                }
                field(StartingDate; Rec."Starting Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the date from which the price is valid.';
                }
                field(EndingDate; Rec."Ending Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the last date that the price is valid.';
                }
                field("Product No."; Rec."Product No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the identifier of the product. If no product is selected, the price and discount values will apply to all products of the selected product type for which those values are not specified. For example, if you choose Item as the product type but do not specify a specific item, the price will apply to all items for which a price is not specified.';
                    Style = Attention;
                    StyleExpr = LineToVerify;
                    ShowMandatory = true;

                    trigger OnValidate()
                    begin
                        CurrPage.Update(true);
                    end;
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the description of the product.';
                    Style = Attention;
                    StyleExpr = LineToVerify;
                }
                field("Variant Code Lookup"; Rec."Variant Code Lookup")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the item variant.';
                    Visible = false;
                }
                field("Unit of Measure Code Lookup"; Rec."Unit of Measure Code Lookup")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the unit of measure for the product.';
                }
                field("Minimum Quantity"; Rec."Minimum Quantity")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the minimum quantity of the product.';
                }
                field("Amount Type"; Rec."Amount Type")
                {
                    ApplicationArea = All;
                    Importance = Standard;
                    ToolTip = 'Specifies whether the price list line defines prices, discounts, or both.';
                    trigger OnValidate()
                    begin
                        SetMandatoryAmount();
                    end;
                }
                field("Unit Price"; Rec."Unit Price")
                {
                    AccessByPermission = tabledata "Sales Price Access" = R;
                    ApplicationArea = All;
                    Editable = AmountEditable;
                    Enabled = PriceMandatory;
                    StyleExpr = PriceStyle;
                    ToolTip = 'Specifies the unit price of the product.';
                }
                field("Allow Line Disc."; Rec."Allow Line Disc.")
                {
                    ApplicationArea = All;
                    Enabled = PriceMandatory;
                    Editable = PriceMandatory;
                    ToolTip = 'Specifies if a line discount will be calculated when the price is offered.';
                }
                field("Line Discount %"; Rec."Line Discount %")
                {
                    AccessByPermission = tabledata "Sales Discount Access" = R;
                    ApplicationArea = All;
                    Enabled = DiscountMandatory;
                    Editable = DiscountMandatory;
                    StyleExpr = DiscountStyle;
                    ToolTip = 'Specifies the line discount percentage for the product.';
                }
                field("Allow Invoice Disc."; Rec."Allow Invoice Disc.")
                {
                    ApplicationArea = All;
                    Enabled = PriceMandatory;
                    Editable = PriceMandatory;
                    Visible = false;
                    ToolTip = 'Specifies if an invoice discount will be calculated when the price is offered.';
                }
                field(PriceIncludesVAT; Rec."Price Includes VAT")
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the if prices include VAT.';
                }
                field(VATBusPostingGrPrice; Rec."VAT Bus. Posting Gr. (Price)")
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the default VAT business posting group code.';
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
                ApplicationArea = All;
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
                    ApplicationArea = Basic, Suite;
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
            }
        }
    }

    trigger OnOpenPage()
    begin
        GetRecFilters();
        SetRecFilters();
        SetCaption();
    end;

    trigger OnAfterGetRecord()
    begin
        UpdateSourceType();
        SetSourceNoEnabled();
        LineToVerify := Rec.IsLineToVerify();
        SetMandatoryAmount();
    end;

    trigger OnAfterGetCurrRecord()
    begin
        SetEditable();
        LineExists := Rec."Price List Code" <> '';
        UpdateSourceType();
        SetSourceNoEnabled();
        LineToVerify := Rec.IsLineToVerify();
        SetMandatoryAmount();
        SalesCodeControlEditable := SetSalesCodeEditable(Rec."Source Type");
    end;

    trigger OnInit()
    begin
        SalesCodeFilterCtrlEnable := true;
        SalesCodeControlEditable := true;
    end;

    trigger OnInsertRecord(BelowxRec: Boolean): Boolean
    begin
        Rec.SetNextLineNo();
        Rec."Asset Type" := Rec."Asset Type"::Item;
        Rec.TestField("Price List Code");
    end;

    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        Rec."Price List Code" := PriceListManagement.GetDefaultPriceListCode(Rec."Price Type"::Sale, Rec."Source Group"::Customer, true);
        Rec."Asset Type" := Rec."Asset Type"::Item;
    end;

    var
        PriceListManagement: Codeunit "Price List Management";
        SourceType: Enum "Sales Price Source Type";
        SourceNoEnabled: Boolean;
        LineToVerify: Boolean;
        Cust: Record Customer;
        CustomerPriceGroup: Record "Customer Price Group";
        CustomerDiscountGroup: Record "Customer Discount Group";
        Campaign: Record Campaign;
        Contact: Record Contact;
        PriceUXManagement: Codeunit "Price UX Management";
        StartingDateFilter: Text;
        CurrencyCodeFilter: Text;
        PageCaptionText: Text;
        Text001: Label 'No %1 within the filter %2.';
        SalesCodeFilterCtrlEnable: Boolean;
        SalesTypeControlEditable: Boolean;
        SalesCodeControlEditable: Boolean;
        DiscountMandatory: Boolean;
        DiscountStyle: Text;
        PriceMandatory: Boolean;
        PriceStyle: Text;
        AmountEditable: Boolean;
        PriceListCodeEditable: Boolean;
        LineExists: Boolean;

    protected var
        SourceTypeFilter: Enum "Sales Price Source Type Filter";
        SalesCodeFilter: Text;
        ItemNoFilter: Text;

    local procedure GetStyle(Mandatory: Boolean): Text;
    begin
        if LineToVerify and Mandatory then
            exit('Attention');
        if Mandatory then
            exit('Strong');
        exit('Subordinate');
    end;

    local procedure SetEditable()
    begin
        AmountEditable := Rec.IsAmountSupported();
        PriceListCodeEditable := Rec."Line No." = 0;
    end;

    local procedure SetMandatoryAmount()
    begin
        DiscountMandatory := Rec.IsAmountMandatory(Rec."Amount Type"::Discount);
        DiscountStyle := GetStyle(DiscountMandatory);
        PriceMandatory := Rec.IsAmountMandatory(Rec."Amount Type"::Price);
        PriceStyle := GetStyle(PriceMandatory);
    end;

    local procedure GetRecFilters()
    begin
        if Rec.GetFilters() <> '' then
            UpdateBasicRecFilters();

        Evaluate(StartingDateFilter, Rec.GetFilter("Starting Date"));
    end;

    local procedure UpdateBasicRecFilters()
    begin
        SourceTypeFilter := GetSalesTypeFilter();
        SalesCodeFilter := Rec.GetFilter("Assign-to No.");
        ItemNoFilter := Rec.GetFilter("Product No.");
        CurrencyCodeFilter := Rec.GetFilter("Currency Code");
    end;

    procedure SetRecFilters()
    begin
        SalesCodeFilterCtrlEnable := true;

        if SourceTypeFilter <> SourceTypeFilter::None then
            Rec.SetRange("Source Type", SourceTypeFilter.AsInteger())
        else
            Rec.SetFilter("Source Type", '%1|%2|%3|%4|%5|%6',
                "Sales Price Source Type"::"All Customers".AsInteger(),
                "Sales Price Source Type"::Customer.AsInteger(),
                "Sales Price Source Type"::"Customer Price Group".AsInteger(),
                "Sales Price Source Type"::"Customer Disc. Group".AsInteger(),
                "Sales Price Source Type"::Campaign.AsInteger(),
                "Sales Price Source Type"::Contact.AsInteger());

        if SourceTypeFilter in [SourceTypeFilter::"All Customers", SourceTypeFilter::None] then begin
            SalesCodeFilterCtrlEnable := false;
            SalesCodeFilter := '';
        end;

        if SalesCodeFilter <> '' then
            Rec.SetFilter("Assign-to No.", SalesCodeFilter)
        else
            Rec.SetRange("Assign-to No.");

        if StartingDateFilter <> '' then
            Rec.SetFilter("Starting Date", StartingDateFilter)
        else
            Rec.SetRange("Starting Date");

        Rec.SetRange("Asset Type", Rec."Asset Type"::Item);
        if ItemNoFilter <> '' then
            Rec.SetFilter("Product No.", ItemNoFilter)
        else
            Rec.SetRange("Product No.");

        if CurrencyCodeFilter <> '' then
            Rec.SetFilter("Currency Code", CurrencyCodeFilter)
        else
            Rec.SetRange("Currency Code");

        case SourceTypeFilter of
            SourceTypeFilter::Customer:
                CheckFilters(DATABASE::Customer, SalesCodeFilter);
            SourceTypeFilter::"Customer Price Group":
                CheckFilters(DATABASE::"Customer Price Group", SalesCodeFilter);
            SourceTypeFilter::Campaign:
                CheckFilters(DATABASE::Campaign, SalesCodeFilter);
        end;
        CheckFilters(DATABASE::Item, ItemNoFilter);
        CheckFilters(DATABASE::Currency, CurrencyCodeFilter);

        SetEditableFields();
        CurrPage.Update(false);
    end;

    local procedure SetCaption()
    begin
        PageCaptionText := GetFilterDescription();
    end;

    local procedure GetFilterDescription(): Text
    var
        ObjTranslation: Record "Object Translation";
        SourceTableName: Text;
        SalesSrcTableName: Text;
        Description: Text;
    begin
        GetRecFilters();

        SourceTableName := '';
        if ItemNoFilter <> '' then
            SourceTableName := ObjTranslation.TranslateObject(ObjTranslation."Object Type"::Table, Database::Item);

        SalesSrcTableName := '';
        Description := '';
        case SourceTypeFilter of
            SourceTypeFilter::Customer:
                begin
                    SalesSrcTableName := ObjTranslation.TranslateObject(ObjTranslation."Object Type"::Table, Database::Customer);
                    Cust."No." := CopyStr(SalesCodeFilter, 1, MaxStrLen(Cust."No."));
                    if Cust.Find() then
                        Description := Cust.Name;
                end;
            SourceTypeFilter::"Customer Price Group":
                begin
                    SalesSrcTableName := ObjTranslation.TranslateObject(ObjTranslation."Object Type"::Table, Database::"Customer Price Group");
                    CustomerPriceGroup.Code := CopyStr(SalesCodeFilter, 1, MaxStrLen(CustomerPriceGroup.Code));
                    if CustomerPriceGroup.Find() then
                        Description := CustomerPriceGroup.Description;
                end;
            SourceTypeFilter::"Customer Disc. Group":
                begin
                    SalesSrcTableName := ObjTranslation.TranslateObject(ObjTranslation."Object Type"::Table, Database::"Customer Discount Group");
                    CustomerDiscountGroup.Code := CopyStr(SalesCodeFilter, 1, MaxStrLen(CustomerDiscountGroup.Code));
                    if CustomerDiscountGroup.Find() then
                        Description := CustomerDiscountGroup.Description;
                end;
            SourceTypeFilter::Campaign:
                begin
                    SalesSrcTableName := ObjTranslation.TranslateObject(ObjTranslation."Object Type"::Table, Database::Campaign);
                    Campaign."No." := CopyStr(SalesCodeFilter, 1, MaxStrLen(Campaign."No."));
                    if Campaign.Find() then
                        Description := Campaign.Description;
                end;
            SourceTypeFilter::Contact:
                begin
                    SalesSrcTableName := ObjTranslation.TranslateObject(ObjTranslation."Object Type"::Table, Database::Contact);
                    Contact."No." := CopyStr(SalesCodeFilter, 1, MaxStrLen(Contact."No."));
                    if Contact.Find() then
                        Description := Contact.Name;
                end;
            SourceTypeFilter::"All Customers":
                SalesSrcTableName := "Sales Price Source Type Filter".Names().Get(1);
        end;

        if SalesSrcTableName = SalesSrcTableName then
            exit(StrSubstNo('%1 %2 %3', SalesSrcTableName, SourceTableName, ItemNoFilter));
        exit(StrSubstNo('%1 %2 %3 %4 %5', SalesSrcTableName, SalesCodeFilter, Description, SourceTableName, ItemNoFilter));
    end;

    local procedure CheckFilters(TableNo: Integer; FilterTxt: Text)
    var
        FilterRecordRef: RecordRef;
        FilterFieldRef: FieldRef;
    begin
        if FilterTxt = '' then
            exit;
        Clear(FilterRecordRef);
        Clear(FilterFieldRef);
        FilterRecordRef.Open(TableNo);
        FilterFieldRef := FilterRecordRef.Field(1);
        FilterFieldRef.SetFilter(FilterTxt);
        if FilterRecordRef.IsEmpty() then
            Error(Text001, FilterRecordRef.Caption, FilterTxt);
    end;

    local procedure SalesCodeFilterOnAfterValidate()
    begin
        CurrPage.SaveRecord();
        SetRecFilters();
        SetCaption();
    end;

    local procedure SalesTypeFilterOnAfterValidate()
    begin
        CurrPage.SaveRecord();
        SalesCodeFilter := '';
        SetRecFilters();
        SetCaption();
    end;

    local procedure StartingDateFilterOnAfterValid()
    begin
        CurrPage.SaveRecord();
        SetRecFilters();
    end;

    local procedure ItemNoFilterOnAfterValidate()
    begin
        CurrPage.SaveRecord();
        SetRecFilters();
        SetCaption();
    end;

    local procedure CurrencyCodeFilterOnAfterValid()
    begin
        CurrPage.SaveRecord();
        SetRecFilters();
    end;

    local procedure GetSalesTypeFilter(): Enum "Sales Price Source Type Filter";
    begin

        case Rec.GetFilter("Source Type") of
            Format(Rec."Source Type"::"All Customers"):
                exit("Sales Price Source Type Filter"::"All Customers");
            Format(Rec."Source Type"::Customer):
                exit("Sales Price Source Type Filter"::Customer);
            Format(Rec."Source Type"::"Customer Price Group"):
                exit("Sales Price Source Type Filter"::"Customer Price Group");
            Format(Rec."Source Type"::"Customer Disc. Group"):
                exit("Sales Price Source Type Filter"::"Customer Disc. Group");
            Format(Rec."Source Type"::Campaign):
                exit("Sales Price Source Type Filter"::Campaign);
            Format(Rec."Source Type"::Contact):
                exit("Sales Price Source Type Filter"::Contact);
            else
                exit("Sales Price Source Type Filter"::None)
        end;
    end;

    local procedure SetSalesCodeEditable(SalesType: Enum "Sales Price Type"): Boolean
    begin
        exit(SalesType <> Rec."Source Type"::"All Customers");
    end;

    local procedure SetEditableFields()
    begin
        SalesTypeControlEditable := Rec.GetFilter("Source Type") = '';
        SalesCodeControlEditable :=
          SalesCodeControlEditable and (Rec.GetFilter("Assign-to No.") = '');
    end;

    local procedure FilterLines()
    var
        FilterPageBuilder: FilterPageBuilder;
    begin
        FilterPageBuilder.AddTable(Rec.TableCaption, DATABASE::"Price List Line");

        FilterPageBuilder.SetView(Rec.TableCaption, Rec.GetView());
        if Rec.GetFilter("Source Type") = '' then
            FilterPageBuilder.AddFieldNo(Rec.TableCaption, Rec.FieldNo("Source Type"));
        if Rec.GetFilter("Assign-to No.") = '' then
            FilterPageBuilder.AddFieldNo(Rec.TableCaption, Rec.FieldNo("Assign-to No."));
        if Rec.GetFilter("Product No.") = '' then
            FilterPageBuilder.AddFieldNo(Rec.TableCaption, Rec.FieldNo("Product No."));
        if Rec.GetFilter("Starting Date") = '' then
            FilterPageBuilder.AddFieldNo(Rec.TableCaption, Rec.FieldNo("Starting Date"));
        if Rec.GetFilter("Currency Code") = '' then
            FilterPageBuilder.AddFieldNo(Rec.TableCaption, Rec.FieldNo("Currency Code"));

        if FilterPageBuilder.RunModal() then
            Rec.SetView(FilterPageBuilder.GetView(Rec.TableCaption));

        UpdateBasicRecFilters();
        Evaluate(StartingDateFilter, Rec.GetFilter("Starting Date"));
        SetEditableFields();
    end;

    local procedure UpdateSourceType()
    begin
        SourceType := "Sales Price Source Type".FromInteger(Rec."Source Type".AsInteger());
    end;

    protected procedure SetSourceNoEnabled()
    begin
        SourceNoEnabled := Rec.IsSourceNoAllowed();
    end;

    protected procedure ValidateSourceType(SourceType: Integer)
    begin
        Rec.Validate("Source Type", SourceType);
        SetSourceNoEnabled();
        CurrPage.Update(true);
    end;

}