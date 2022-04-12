/// <summary>
/// PageExtension Shpfy Sales and Marketing RC (ID 30103) extends Record Sales and Marketing Manager RC.
/// </summary>
pageextension 30103 "Shpfy Sales & Marketing RC" extends "Sales & Marketing Manager RC"
{
    actions
    {
        addlast(Sections)
        {
            group(Shpfy)
            {
                Caption = 'Shopify';
                ToolTip = 'Manage Shopify Shops, customers, products, orders, gift cards, transactions and payouts.';

                action(ShpfyShops)
                {
                    ApplicationArea = All;
                    Caption = 'Shops';
                    Image = Web;
                    RunObject = page "Shpfy Shops";
                    ToolTip = 'Define your Shopify Shops and enter how to synchronize data for each shop.';
                }
                action(ShpfyCustomers)
                {
                    ApplicationArea = All;
                    Caption = 'Customers';
                    Image = CustomerList;
                    RunObject = page "Shpfy Customers";
                    ToolTip = 'View or edit detailed information for the customers that you trade with through Shopify.';
                }
                action(ShpfyProducts)
                {
                    ApplicationArea = All;
                    Caption = 'Products';
                    Image = ItemLines;
                    RunObject = page "Shpfy Products";
                    ToolTip = 'Add, view or edit detailed information for the products that you trade in through Shopify.';
                }
                action(ShpfyOrders)
                {
                    ApplicationArea = All;
                    Caption = 'Orders';
                    Image = OrderList;
                    RunObject = page "Shpfy Orders";
                    RunPageView = where(Closed = const(false));
                    ToolTip = 'View your Shopify agreements with customers to sell certain products on certain delivery and payment terms.';
                }
                action(ShpfyGiftCards)
                {
                    ApplicationArea = All;
                    Caption = 'Gift Cards';
                    Image = Voucher;
                    RunObject = page "Shpfy Gift Cards";
                    ToolTip = 'View the Shopify Gift Cards, their unique code and balance.';
                }
                action(ShpfyTransactions)
                {
                    ApplicationArea = All;
                    Caption = 'Transactions';
                    Image = Transactions;
                    RunObject = page "Shpfy Transactions";
                    ToolTip = 'View every single movement of money in or uoutit the Shopify Payment account.';
                }
                action(ShpfyPayouts)
                {
                    ApplicationArea = All;
                    Caption = 'Payouts';
                    Image = PaymentHistory;
                    RunObject = page "Shpfy Payouts";
                    ToolTip = 'View the movement of money between a Shopify Payment account balance and a connected bank account.';
                }
            }
        }
    }
}