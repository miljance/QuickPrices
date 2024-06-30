namespace QuickPrices.QuickPrices;

using Microsoft.Inventory.Item;
using Microsoft.Pricing.PriceList;
using Microsoft.Sales.Pricing;

pageextension 50101 "Item Card" extends "Item Card"
{
    actions
    {
        addbefore(SalesPriceLists)
        {
            action(PriceOverview)
            {
                AccessByPermission = TableData "Sales Price Access" = R;
                ApplicationArea = Basic, Suite;
                Caption = 'Price Overview';
                Image = Price;
                Scope = Repeater;
                Visible = ExtendedPriceEnabled;
                ToolTip = 'Overview of all prices, costs and discounts setup for an item.';
                RunObject = page "Item Prices Overview";
                RunPageLink = "Asset No." = field("No.");
            }
        }
        addbefore(SalesPriceLists_Promoted)
        {
            actionref(PriceOverview_Promoted; PriceOverview)
            {
            }
        }
    }
}
