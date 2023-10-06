from flask import Flask, request, jsonify
import requests
import json
from ebay_oauth_token import OAuthToken 

client_id = "YiweiCai-571HW2-PRD-1da0f0f3a-d12e812a"
client_secret = "PRD-da0f0f3a4527-e9ab-4725-ad29-82df"
token_object = OAuthToken(client_id, client_secret)

app = Flask(__name__, static_folder="static")

@app.route("/", methods=['GET'])
def index():
    return app.send_static_file("index.html")



def call_ebay_search_api(query, minPrice=None, maxPrice=None, conditions=None, returnsAccepted=None, shippingTypes=None, sortOrder=None):
    
    if sortOrder is None:
        sortOrder = "BestMatch"

    url = "https://svcs.ebay.com/services/search/FindingService/v1"
    headers = {
        "X-EBAY-SOA-OPERATION-NAME": "findItemsAdvanced",
        "X-EBAY-SOA-SERVICE-VERSION": "1.0.0",
        "X-EBAY-SOA-SECURITY-APPNAME": client_id,
        "X-EBAY-SOA-RESPONSE-DATA-FORMAT": "JSON"
    }
    params = {
        "OPERATION-NAME": "findItemsAdvanced",
        "SERVICE-VERSION": "1.0.0",
        "SECURITY-APPNAME": client_id,
        "RESPONSE-DATA-FORMAT": "JSON",
        "REST-PAYLOAD": "",
        "keywords": query,
        "sortOrder": sortOrder,
        "paginationInput.entriesPerPage": "10"
    }

    filter_index = 0
    
    if minPrice:
        params[f"itemFilter({filter_index}).name"] = "MinPrice"
        params[f"itemFilter({filter_index}).value"] = minPrice
        filter_index += 1

    if maxPrice:
        params[f"itemFilter({filter_index}).name"] = "MaxPrice"
        params[f"itemFilter({filter_index}).value"] = maxPrice
        filter_index += 1

    if conditions:
        params[f"itemFilter({filter_index}).name"] = "Condition"
        for i, condition in enumerate(conditions):
            params[f"itemFilter({filter_index}).value({i})"] = condition
        filter_index += 1

    if returnsAccepted:
        params[f"itemFilter({filter_index}).name"] = "ReturnsAcceptedOnly"
        params[f"itemFilter({filter_index}).value"] = "true"
        filter_index += 1

    if shippingTypes: 
        if shippingTypes[0] == "Free":
            params[f"itemFilter({filter_index}).name"] = "FreeShippingOnly"
            params[f"itemFilter({filter_index}).value"] = "true"
            filter_index += 1
            
        

    response = requests.get(url, headers=headers, params=params)
    if response.status_code == 200:
        response_data = response.json()  
        search_results = response_data.get("findItemsAdvancedResponse", [{}])[0].get("searchResult", [{}])[0].get("item", [])
        pagination_output = response_data.get("findItemsAdvancedResponse", [{}])[0].get('paginationOutput', [{}])[0]
        total_entries = int(pagination_output.get('totalEntries', [0])[0])
        simplified_results = []
        for item in search_results:
            simplified_item = {
                'itemID': item.get('itemId', [None])[0],
                'title': item.get('title', [''])[0],
                'itemUrl' : item.get('viewItemURL', [''])[0],
                'image': item.get('galleryURL', [''])[0],
                'category': item.get('primaryCategory', [{}])[0].get('categoryName', [''])[0],
                'condition': item.get('condition', [{}])[0].get('conditionDisplayName', [''])[0],
                'price': item.get('sellingStatus', [{}])[0].get('convertedCurrentPrice', [{}])[0].get('__value__', ''),
                'topRated': item.get('topRatedListing', False)[0],
                'shippingFee': item.get('shippingInfo', [{}])[0].get('shippingServiceCost', [{}])[0].get('__value__', ''),    
                'returnsAccepted': item.get('returnsAccepted', [False])[0]
                
            }
            simplified_results.append(simplified_item)
        return simplified_results, total_entries
    else:
        return [], 0

@app.route('/search', methods=['GET'])
def search():
    query = request.args.get('query')
    minPrice = request.args.get('minPrice')
    maxPrice = request.args.get('maxPrice')
    conditions = request.args.getlist('condition')
    returnsAccepted = request.args.get('seller') 
    shippingTypes = request.args.getlist('shipping')
    sortOrder = request.args.get('sortOrder')


    if not query:
        return jsonify({"error": "Missing query parameter"}), 400

    search_results, total_results  = call_ebay_search_api(query, minPrice, maxPrice, conditions, returnsAccepted, shippingTypes, sortOrder)
     
    if total_results == 0:
        return jsonify({'results': [], 'total': 0, 'message': 'No Results found'})

    print("Search Results:")
    print(json.dumps(search_results, indent=4))
    print("Total_result:" , total_results)
    
    return jsonify({'results': search_results, 'total': total_results})



@app.route('/getSingleItem/<itemId>', methods=['GET'])
def get_single_item(itemId):
    global access_token  
    access_token = token_object.getApplicationToken()  

    ebay_api_url = f"https://open.api.ebay.com/shopping?callname=GetSingleItem&responseencoding=JSON&siteid=0&version=967&IncludeSelector=Details,ItemSpecifics,ShippingCosts&ItemID={itemId}"
    headers = {
        "X-EBAY-API-APP-ID": client_id,
        "X-EBAY-API-IAF-TOKEN": access_token
    }
    response = requests.get(ebay_api_url, headers=headers)
    response_data = response.json()

    if 'Item' not in response_data:
        return jsonify({"error": "Item not found"}), 404

    item = response_data['Item']

    extracted_data = {
        "Photo": item.get("PictureURL", "N/A"),
        "eBayLinkTitle": item.get("ViewItemURLForNaturalSearch", "N/A"),
        "Title": item.get("Title", "N/A"),
        "SubTitle": item.get("Subtitle", "N/A"),
        "Price": item.get("CurrentPrice", {}).get("Value", "N/A"),
        "Location": item.get("Location", "N/A"),
        "PostalCode": item.get("PostalCode", "N/A"),
        "Seller": item.get("Seller", {}).get("UserID", "N/A"),
        "ReturnPolicy": item.get("ReturnPolicy", "N/A"),
        "ItemSpecifics": item.get("ItemSpecifics", {}).get("NameValueList", [])
    }

    
    print(json.dumps(extracted_data, indent=4))
    return jsonify(extracted_data)



if __name__ == '__main__':
    app.run(host='0.0.0.0', port=8080)
    
