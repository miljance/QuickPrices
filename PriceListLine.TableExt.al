namespace QuickPrices.QuickPrices;

using Microsoft.Pricing.PriceList;

tableextension 50100 PriceListLine extends "Price List Line"
{

    trigger OnRename()
    begin
        Error(PriceListCodeChangeErr, Rec.FieldCaption("Price List Code"));
    end;

    var
        PriceListCodeChangeErr: Label 'You cannot change %1 for existing price list line.';

}
