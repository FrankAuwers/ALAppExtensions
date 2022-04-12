/// <summary>
/// Page Shpfy Orders To Import (ID 30121).
/// </summary>
page 30121 "Shpfy Orders To Import"
{

    ApplicationArea = All;
    Caption = 'Shopify Orders To Import';
    PageType = List;
    SourceTable = "Shpfy Orders To Import";
    UsageCategory = Lists;
    InsertAllowed = false;
    ModifyAllowed = false;
    DeleteAllowed = true;

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field(Id; Rec.Id)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the id for the order in Shopify.';
                }
                field(ShopCode; Rec."Shop Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the Shopify Shop from which the order originated.';
                }
                field(OrderNo; Rec."Order No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the order number from Shopify.';
                }
                field("Action"; Rec."Action")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the action to take for this order.';
                }
                field(NumberOfItems; Rec."Number of Items")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the sum of the line quantities on all lines in the document.';
                }
                field(OrderAmount; Rec."Order Amount")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the sum of the line amounts on all lines in the document minus any discount amounts.';
                }
                field(CurrencyCode; Rec."Currency Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the currency code from Shopify.';
                }
                field(Unpaid; Rec.Unpaid)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the order from Shopify is unpaid.';
                }
                field(FullyPaid; Rec."Fully Paid")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the order from Shopify is fully paid.';
                }
                field(FinancialStatus; Rec."Financial Status")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the status of payments associated with the order. Valid values are: pending, authorized, partially_paid, paid, partially_refunded, refunded, voided.';
                }
                field(RiskLevel; Rec."Risk Level")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the risk level from the Shopify order.';
                }
                field(FulfillmentStatus; Rec."Fulfillment Status")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the order''s status in terms of fulfilled line items. Valid values are: Fulfilled, null, partial, restocked.';
                }
                field(Confirmed; Rec.Confirmed)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies whether the order has been confirmed.';
                }
                field(Tags; Rec.Tags)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the tags that are set on this Shopify order.';
                }
                field(CreatedAt; Rec."Created At")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the autogenerated date and time when the order was created in Shopify.';
                }
                field(UpdatedAt; Rec."Updated At")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the date and time when the order was last modified.';
                }
                field(Test; Rec.Test)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies if this is an test order.';
                }
                field(HasError; Rec."Has Error")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies if this order have processing errors.';
                }
            }
            group(ErrorInfo)
            {
                Caption = 'Error Info';
                Visible = Rec."Has Error";

                field(ErrorMsg; Rec.GetErrorMessage())
                {
                    Caption = 'Error';
                    ApplicationArea = All;
                    MultiLine = true;
                    ToolTip = 'Specifies the processing error message.';
                }
                field(CallStack; Rec.GetErrorCallStack())
                {
                    Caption = 'Error Call Stack';
                    ApplicationArea = All;
                    MultiLine = true;
                    ToolTip = 'Specifies the processing error callstack.';
                }
            }
        }
        area(FactBoxes)
        {
            part(Attributes; "Shpfy Order Attributes")
            {
                Caption = 'Attributes';
                ApplicationArea = All;
                SubPageLink = "Order Id" = field(Id);
            }
        }
    }

    actions
    {
        area(Processing)
        {
            Action(GetOrdersToImport)
            {
                Caption = 'Get Orders to Import';
                ApplicationArea = All;
                Image = RefreshLines;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                PromotedOnly = true;
                ToolTip = 'Retrieves the order from Shopify.';

                trigger OnAction()
                begin
                    Codeunit.Run(Codeunit::"Shpfy Orders API");
                end;
            }

            Action(StartImport)
            {
                Caption = 'Import Selected Orders';
                ApplicationArea = All;
                Image = Import;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                PromotedOnly = true;
                ToolTip = 'Import the selected orders into Shopify Orders page.';

                trigger OnAction()
                var
                    SelectedRec: Record "Shpfy Orders To Import";
                    Background: Codeunit "Shpfy Background Syncs";
                begin
                    CurrPage.SetSelectionFilter(SelectedRec);
                    Background.OrderSync(SelectedRec);
                end;
            }
        }
    }

}