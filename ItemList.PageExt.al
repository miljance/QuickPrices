namespace QuickPrices.QuickPrices;

using Microsoft.Inventory.Item;
using Microsoft.Sales.Pricing;
using Microsoft.Pricing.PriceList;

pageextension 50100 "Item List" extends "Item List"
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
