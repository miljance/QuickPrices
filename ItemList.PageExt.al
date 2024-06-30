namespace QuickPrices.QuickPrices;

using Microsoft.Inventory.Item;
using Microsoft.Sales.Pricing;

pageextension 50100 "Item List" extends "Item List"
{
    actions
    {
        addbefore(SalesPriceLists)
        {
            action(SalesPricesAndDiscounts)
            {
                AccessByPermission = TableData "Sales Price Access" = R;
                ApplicationArea = Basic, Suite;
                Caption = 'Sales Prices and Discounts';
                Image = Price;
                Scope = Repeater;
                Visible = ExtendedPriceEnabled;
                ToolTip = 'Set up sales prices and discounts for the item.';
                RunObject = page "Item Sales Prices";
                RunPageLink = "Product No." = field("No.");
            }
        }
        addbefore(SalesPriceLists_Promoted)
        {
            actionref(SalesPricesAndDiscounts_Promoted; SalesPricesAndDiscounts)
            {
            }
        }
    }
}
