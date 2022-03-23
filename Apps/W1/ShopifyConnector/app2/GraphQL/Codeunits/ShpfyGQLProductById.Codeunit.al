/// <summary>
/// Codeunit Shpfy GQL ProductById (ID 70007691) implements Interface Shpfy IGarphQL.
/// </summary>
codeunit 30146 "Shpfy GQL ProductById" implements "Shpfy IGraphQL"
{

    /// <summary>
    /// GetGraphQL.
    /// </summary>
    /// <returns>Return value of type Text.</returns>
    procedure GetGraphQL(): Text
    begin
        exit('{"query":"{product(id: \"gid://shopify/Product/{{ProductId}}\") {createdAt updatedAt hasOnlyDefaultVariant description(truncateAt: {{MaxLengthDescription}}) descriptionHtml onlineStorePreviewUrl onlineStoreUrl productType status tags title vendor seo{description, title} images(first: 1) {edges{node{id}}} metafields(namespace: \"D365BC\", first: 10) {edges {node {id namespace type legacyResourceId key value}}}}}"}');
    end;

    /// <summary>
    /// GetExpectedCost.
    /// </summary>
    /// <returns>Return value of type Integer.</returns>
    procedure GetExpectedCost(): Integer
    begin
        exit(25);
    end;

}
