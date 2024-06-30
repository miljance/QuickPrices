report 50100 "Import Prices from Excel"
{
    Caption = 'Import Prices from Excel';
    ProcessingOnly = true;

    dataset
    {
    }

    requestpage
    {

        layout
        {
            area(content)
            {
                group(Options)
                {
                    Caption = 'Options';
                    field(FileNameControl; FileName)
                    {
                        ApplicationArea = All;
                        Caption = 'Workbook File Name';
                        Editable = false;

                        trigger OnAssistEdit()
                        begin
                            UploadFile();
                        end;
                    }
                    field(SheetNameControl; SheetName)
                    {
                        ApplicationArea = SITE;
                        Caption = 'Worksheet Name';
                        Editable = false;

                        trigger OnAssistEdit()
                        var
                            LocalSheetName: Text[250];
                        begin
                            if FileName = '' then
                                UploadFile()
                            else begin
                                LocalSheetName := TempExcelBuffer.SelectSheetsNameStream(ExcelInStream);
                                if LocalSheetName <> '' then
                                    SheetName := LocalSheetName;
                            end;
                        end;
                    }
                }
            }
        }
    }

    labels
    {
    }

    trigger OnPostReport()
    var
        TempHeaderExcelBuffer: Record "Excel Buffer" temporary;
        HeaderRowNo: Integer;
        OldRowNo: Integer;
    begin
        TempExcelBuffer.DeleteAll();
        TempExcelBuffer.OpenBookStream(ExcelInStream, SheetName);
        TempExcelBuffer.ReadSheet();
        TempExcelBuffer.SetRange("Row No.", 1);
        if TempExcelBuffer.FindSet() then
            repeat
                case true of
                    TempExcelBuffer."Cell Value as Text" = PriceListLine.FieldCaption("Price List Code"):
                        InsertTempExcelBuffer(TempExcelBuffer, TempHeaderExcelBuffer, PriceListLine.FieldCaption("Price List Code"));
                    TempExcelBuffer."Cell Value as Text" = PriceListLine.FieldCaption("Price Type"):
                        InsertTempExcelBuffer(TempExcelBuffer, TempHeaderExcelBuffer, PriceListLine.FieldCaption("Price Type"));
                    TempExcelBuffer."Cell Value as Text" = PriceListLine.FieldCaption("Source Type"):
                        InsertTempExcelBuffer(TempExcelBuffer, TempHeaderExcelBuffer, PriceListLine.FieldCaption("Source Type"));
                    TempExcelBuffer."Cell Value as Text" = PriceListLine.FieldCaption("Assign-to Parent No."):
                        InsertTempExcelBuffer(TempExcelBuffer, TempHeaderExcelBuffer, PriceListLine.FieldCaption("Assign-to Parent No."));
                    TempExcelBuffer."Cell Value as Text" = PriceListLine.FieldCaption("Assign-to No."):
                        InsertTempExcelBuffer(TempExcelBuffer, TempHeaderExcelBuffer, PriceListLine.FieldCaption("Assign-to No."));
                    TempExcelBuffer."Cell Value as Text" = PriceListLine.FieldCaption("Product No."):
                        InsertTempExcelBuffer(TempExcelBuffer, TempHeaderExcelBuffer, PriceListLine.FieldCaption("Product No."));
                    TempExcelBuffer."Cell Value as Text" = PriceListLine.FieldCaption("Variant Code Lookup"):
                        InsertTempExcelBuffer(TempExcelBuffer, TempHeaderExcelBuffer, PriceListLine.FieldCaption("Variant Code Lookup"));
                    TempExcelBuffer."Cell Value as Text" = PriceListLine.FieldCaption("Currency Code"):
                        InsertTempExcelBuffer(TempExcelBuffer, TempHeaderExcelBuffer, PriceListLine.FieldCaption("Currency Code"));
                    TempExcelBuffer."Cell Value as Text" = PriceListLine.FieldCaption("Unit of Measure Code Lookup"):
                        InsertTempExcelBuffer(TempExcelBuffer, TempHeaderExcelBuffer, PriceListLine.FieldCaption("Unit of Measure Code Lookup"));
                    TempExcelBuffer."Cell Value as Text" = PriceListLine.FieldCaption("Minimum Quantity"):
                        InsertTempExcelBuffer(TempExcelBuffer, TempHeaderExcelBuffer, PriceListLine.FieldCaption("Minimum Quantity"));
                    TempExcelBuffer."Cell Value as Text" = PriceListLine.FieldCaption("Amount Type"):
                        InsertTempExcelBuffer(TempExcelBuffer, TempHeaderExcelBuffer, PriceListLine.FieldCaption("Amount Type"));
                    TempExcelBuffer."Cell Value as Text" = PriceListLine.FieldCaption("Unit Price"):
                        InsertTempExcelBuffer(TempExcelBuffer, TempHeaderExcelBuffer, PriceListLine.FieldCaption("Unit Price"));
                    TempExcelBuffer."Cell Value as Text" = PriceListLine.FieldCaption("Direct Unit Cost"):
                        InsertTempExcelBuffer(TempExcelBuffer, TempHeaderExcelBuffer, PriceListLine.FieldCaption("Direct Unit Cost"));
                    TempExcelBuffer."Cell Value as Text" = PriceListLine.FieldCaption("Unit Cost"):
                        InsertTempExcelBuffer(TempExcelBuffer, TempHeaderExcelBuffer, PriceListLine.FieldCaption("Unit Cost"));
                    TempExcelBuffer."Cell Value as Text" = PriceListLine.FieldCaption("Line Discount %"):
                        InsertTempExcelBuffer(TempExcelBuffer, TempHeaderExcelBuffer, PriceListLine.FieldCaption("Line Discount %"));
                    TempExcelBuffer."Cell Value as Text" = PriceListLine.FieldCaption("Starting Date"):
                        InsertTempExcelBuffer(TempExcelBuffer, TempHeaderExcelBuffer, PriceListLine.FieldCaption("Starting Date"));
                    TempExcelBuffer."Cell Value as Text" = PriceListLine.FieldCaption("Ending Date"):
                        InsertTempExcelBuffer(TempExcelBuffer, TempHeaderExcelBuffer, PriceListLine.FieldCaption("Ending Date"));
                    TempExcelBuffer."Cell Value as Text" = PriceListLine.FieldCaption("Allow Line Disc."):
                        InsertTempExcelBuffer(TempExcelBuffer, TempHeaderExcelBuffer, PriceListLine.FieldCaption("Allow Line Disc."));
                    TempExcelBuffer."Cell Value as Text" = PriceListLine.FieldCaption("Allow Invoice Disc."):
                        InsertTempExcelBuffer(TempExcelBuffer, TempHeaderExcelBuffer, PriceListLine.FieldCaption("Allow Invoice Disc."));
                end;
            until TempExcelBuffer.Next() = 0;
        TempExcelBuffer.SetFilter("Row No.", '>1');
        TempExcelBuffer.SetRange("Column No.", 1);
        TotalRecNo := TempExcelBuffer.Count();
        TempExcelBuffer.SetRange("Column No.");
        if TempExcelBuffer.FindSet() then begin
            Window.Open(ImportingTxt + '@1@@@@@@@@@@@@@@@@@@@@@@@@@\');
            Window.Update(1, 0);
            repeat
                RecNo := RecNo + 1;
                Window.Update(1, Round(RecNo / TotalRecNo * 10000, 1));
                if TempExcelBuffer."Row No." <> OldRowNo then
                    OldRowNo := TempExcelBuffer."Row No.";
                TempHeaderExcelBuffer.SetRange("Column No.", TempExcelBuffer."Column No.");
                if TempHeaderExcelBuffer.FindFirst() then
                    case TempHeaderExcelBuffer.Comment of
                        PriceListLine.FieldCaption("Price List Code"):
                            begin
                                InsertOrUpdatePriceListLineIfPossible(PriceListLine);
                                Clear(PriceListLine);
                                PriceListLine."Price List Code" := TempExcelBuffer."Cell Value as Text";
                                PriceListLine.Init();
                            end;
                        PriceListLine.FieldCaption("Price Type"):
                            Evaluate(PriceListLine."Price Type", TempExcelBuffer."Cell Value as Text");
                        PriceListLine.FieldCaption("Source Type"):
                            Evaluate(PriceListLine."Source Type", TempExcelBuffer."Cell Value as Text");
                        PriceListLine.FieldCaption("Assign-to Parent No."):
                            PriceListLine."Assign-to Parent No." := TempExcelBuffer."Cell Value as Text";
                        PriceListLine.FieldCaption("Assign-to No."):
                            PriceListLine."Assign-to No." := TempExcelBuffer."Cell Value as Text";
                        PriceListLine.FieldCaption("Product No."):
                            PriceListLine."Product No." := TempExcelBuffer."Cell Value as Text";
                        PriceListLine.FieldCaption("Variant Code Lookup"):
                            PriceListLine."Variant Code Lookup" := TempExcelBuffer."Cell Value as Text";
                        PriceListLine.FieldCaption("Currency Code"):
                            PriceListLine."Currency Code" := TempExcelBuffer."Cell Value as Text";
                        PriceListLine.FieldCaption("Unit of Measure Code Lookup"):
                            PriceListLine."Unit of Measure Code Lookup" := TempExcelBuffer."Cell Value as Text";
                        PriceListLine.FieldCaption("Minimum Quantity"):
                            Evaluate(PriceListLine."Minimum Quantity", TempExcelBuffer."Cell Value as Text");
                        PriceListLine.FieldCaption("Amount Type"):
                            Evaluate(PriceListLine."Amount Type", TempExcelBuffer."Cell Value as Text");
                        PriceListLine.FieldCaption("Unit Price"):
                            Evaluate(PriceListLine."Unit Price", TempExcelBuffer."Cell Value as Text");
                        PriceListLine.FieldCaption("Direct Unit Cost"):
                            Evaluate(PriceListLine."Direct Unit Cost", TempExcelBuffer."Cell Value as Text");
                        PriceListLine.FieldCaption("Unit Cost"):
                            Evaluate(PriceListLine."Unit Cost", TempExcelBuffer."Cell Value as Text");
                        PriceListLine.FieldCaption("Line Discount %"):
                            Evaluate(PriceListLine."Line Discount %", TempExcelBuffer."Cell Value as Text");
                        PriceListLine.FieldCaption("Starting Date"):
                            Evaluate(PriceListLine."Starting Date", TempExcelBuffer."Cell Value as Text");
                        PriceListLine.FieldCaption("Ending Date"):
                            Evaluate(PriceListLine."Ending Date", TempExcelBuffer."Cell Value as Text");
                        PriceListLine.FieldCaption("Allow Line Disc."):
                            Evaluate(PriceListLine."Allow Line Disc.", TempExcelBuffer."Cell Value as Text");
                        PriceListLine.FieldCaption("Allow Invoice Disc."):
                            Evaluate(PriceListLine."Allow Invoice Disc.", TempExcelBuffer."Cell Value as Text");
                    end;
            until TempExcelBuffer.Next() = 0;
            InsertOrUpdatePriceListLineIfPossible(PriceListLine);
            Window.Close();
        end else
            Error(NoDataFoundErr);
    end;

    var
        TempExcelBuffer: Record "Excel Buffer" temporary;
        PriceListLine: Record "Price List Line";
        FileManagement: Codeunit "File Management";
        TempBlob: Codeunit "Temp Blob";
        ExcelInStream: InStream;
        Window: Dialog;
        FileName: Text;
        SheetName: Text[250];
        TotalRecNo: Integer;
        RecNo: Integer;
        NoDataFoundErr: Label 'No Data has been found in the Excel.';
        ImportingTxt: Label 'Importing from Excel worksheet';

    local procedure UploadFile()
    begin
        FileName := FileManagement.BLOBImport(TempBlob, '*.xlsx');
        if FileName <> '' then begin
            TempBlob.CreateInStream(ExcelInStream);
            SheetName := TempExcelBuffer.SelectSheetsNameStream(ExcelInStream);
        end;
    end;

    local procedure InsertTempExcelBuffer(var ExcelBuffer: Record "Excel Buffer"; var TempExcelBuffer: Record "Excel Buffer" temporary; Text: Text[250])
    begin
        TempExcelBuffer := ExcelBuffer;
        TempExcelBuffer.Comment := Text;
        TempExcelBuffer.Insert();
    end;

    local procedure InsertOrUpdatePriceListLineIfPossible(var ExcelPriceListLine: Record "Price List Line")
    var
        NewPriceListLine: Record "Price List Line";
    begin
        if ExcelPriceListLine."Price List Code" = '' then
            exit;

        NewPriceListLine.SetRange("Price List Code", ExcelPriceListLine."Price List Code");
        NewPriceListLine.SetRange("Price Type", ExcelPriceListLine."Price Type");
        NewPriceListLine.SetRange("Source Type", ExcelPriceListLine."Source Type");
        NewPriceListLine.SetRange("Assign-to Parent No.", ExcelPriceListLine."Assign-to Parent No.");
        NewPriceListLine.SetRange("Assign-to No.", ExcelPriceListLine."Assign-to No.");
        NewPriceListLine.SetRange("Asset Type", ExcelPriceListLine."Asset Type"::Item);
        NewPriceListLine.SetRange("Product No.", ExcelPriceListLine."Product No.");
        NewPriceListLine.SetRange("Variant Code Lookup", ExcelPriceListLine."Variant Code Lookup");
        NewPriceListLine.SetRange("Currency Code", ExcelPriceListLine."Currency Code");
        NewPriceListLine.SetRange("Unit of Measure Code Lookup", ExcelPriceListLine."Unit of Measure Code Lookup");
        NewPriceListLine.SetRange("Minimum Quantity", ExcelPriceListLine."Minimum Quantity");
        NewPriceListLine.SetRange("Amount Type", ExcelPriceListLine."Amount Type");
        NewPriceListLine.SetRange("Starting Date", ExcelPriceListLine."Starting Date");
        NewPriceListLine.SetRange("Ending Date", ExcelPriceListLine."Ending Date");
        if NewPriceListLine.FindFirst() then begin
            ValidatePriceListLinesAmounts(NewPriceListLine, ExcelPriceListLine);
            NewPriceListLine.Status := NewPriceListLine.Status::Draft;
            NewPriceListLine.Modify();
        end else begin
            Clear(NewPriceListLine);
            NewPriceListLine.Validate("Price List Code", ExcelPriceListLine."Price List Code");
            NewPriceListLine.Validate("Price Type", ExcelPriceListLine."Price Type");
            NewPriceListLine.Validate("Source Type", ExcelPriceListLine."Source Type");
            NewPriceListLine.Validate("Assign-to Parent No.", ExcelPriceListLine."Assign-to Parent No.");
            NewPriceListLine.Validate("Assign-to No.", ExcelPriceListLine."Assign-to No.");
            NewPriceListLine.Validate("Asset Type", ExcelPriceListLine."Asset Type"::Item);
            NewPriceListLine.Validate("Product No.", ExcelPriceListLine."Product No.");
            NewPriceListLine.Validate("Variant Code Lookup", ExcelPriceListLine."Variant Code Lookup");
            NewPriceListLine.Validate("Currency Code", ExcelPriceListLine."Currency Code");
            NewPriceListLine.Validate("Unit of Measure Code Lookup", ExcelPriceListLine."Unit of Measure Code Lookup");
            NewPriceListLine.Validate("Minimum Quantity", ExcelPriceListLine."Minimum Quantity");
            NewPriceListLine.Validate("Amount Type", ExcelPriceListLine."Amount Type");
            NewPriceListLine.Validate("Starting Date", ExcelPriceListLine."Starting Date");
            NewPriceListLine.Validate("Ending Date", ExcelPriceListLine."Ending Date");
            ValidatePriceListLinesAmounts(NewPriceListLine, ExcelPriceListLine);
            NewPriceListLine.Insert();
        end;
    end;

    local procedure ValidatePriceListLinesAmounts(var NewPriceListLine: Record "Price List Line"; var ExcelPriceListLine: Record "Price List Line")
    begin
        case ExcelPriceListLine."Price Type" of
            ExcelPriceListLine."Price Type"::Sale:
                begin
                    NewPriceListLine.Validate("Unit Price", ExcelPriceListLine."Unit Price");
                end;
            ExcelPriceListLine."Price Type"::Purchase:
                begin
                    NewPriceListLine.Validate("Direct Unit Cost", ExcelPriceListLine."Direct Unit Cost");
                    NewPriceListLine.Validate("Unit Cost", ExcelPriceListLine."Unit Cost");
                end;
        end;
        if ExcelPriceListLine."Amount Type" in [ExcelPriceListLine."Amount Type"::Any, ExcelPriceListLine."Amount Type"::Discount] then
            NewPriceListLine.Validate("Line Discount %", ExcelPriceListLine."Line Discount %");
        if ExcelPriceListLine."Amount Type" in [ExcelPriceListLine."Amount Type"::Any, ExcelPriceListLine."Amount Type"::Price] then begin
            NewPriceListLine.Validate("Allow Line Disc.", ExcelPriceListLine."Allow Line Disc.");
            NewPriceListLine.Validate("Allow Invoice Disc.", ExcelPriceListLine."Allow Invoice Disc.");
        end;
    end;
}

