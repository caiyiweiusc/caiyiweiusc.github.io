// 导入需要的模块
const express = require('express');
const axios = require('axios');
const cors = require('cors');
const OAuthToken = require('./ebay_oauth_token');
const { MongoClient, ServerApiVersion } = require('mongodb');
const bodyParser = require('body-parser');
const app = express();
let globalShippingExtractedData = [];  // 定义一个全局变量来存储数据
let globalSellerExtractedData = [];
const path = require('path'); // 导入path模块
const { ConnectableObservable } = require('rxjs');
// 定义API的凭证
const EBAY_APP_KEY = 'YiweiCai-571HW2-PRD-1da0f0f3a-d12e812a';
const EBAY_CERT_ID = 'PRD-da0f0f3a4527-e9ab-4725-ad29-82df';
const GOOGLE_API_KEY = 'AIzaSyCpHCjCV6OMS8ZFx6er1vvWaFdZDxZENXc';
const GOOGLE_CSE_ID = '47a8778f1a4344bee';
const publicPath = path.join(__dirname, 'dist', '571-hw3-app');

  


let EBAY_OAUTH_TOKEN = '';

app.use(cors()); // 使用CORS中间件，允许跨域请求
app.use(bodyParser.json());
app.use(express.static(publicPath)); // 配置静态文件服务

// 获取eBay OAuth令牌的函数
async function fetchEbayOAuthToken() {
    const oauth = new OAuthToken(EBAY_APP_KEY, EBAY_CERT_ID);
    try {
        EBAY_OAUTH_TOKEN = await oauth.getApplicationToken();
        console.log('Successfully fetched eBay OAuth token.');
    } catch (error) {
        console.error('Error fetching eBay OAuth token:', error);
    }
}

//zip填充：
app.get('/searchZipCodes', async (req, res) => {
    const query = req.query.postalcode_startsWith;
    console.log("ZipQuery:", query)
    if (query && query.length >= 3) {
      try {
        const response = await axios.get(`http://api.geonames.org/postalCodeSearchJSON`, {
          params: {
            postalcode_startsWith: query,
            maxRows: 5,
            username: 'ericcaiusc', // 你的用户名
            country: 'US'
          }
        });
        res.json(response.data);
      } catch (error) {
        console.error('Error fetching data:', error);
        res.status(500).send(error);
      }
    } else {
      res.status(400).send('Invalid input');
    }
  });

//Current Location
app.get('/getCurrentLocationZip', async (req, res) => {
    try {
      // 获取IP地址
      const ipRes = await axios.get('https://api64.ipify.org?format=json');
      const userIP = ipRes.data.ip;
      console.log("UserIP: ", userIP)
      // 使用IP地址获取邮政编码
      const infoRes = await axios.get(`https://ipinfo.io/${userIP}?token=9c639fe2247787`);
      const zipCode = infoRes.data.postal;
      console.log("ZZZip:", zipCode)
      res.send({ zip: zipCode });
    } catch (error) {
      res.status(500).send({ error: error.message });
    }
  });
  

// eBay搜索API路由
app.get('/ebay/search', async (req, res) => {
    const baseURL = 'https://svcs.ebay.com/services/search/FindingService/v1';

    // 构建API请求参数
    const params = {
        'OPERATION-NAME': 'findItemsAdvanced',
        'SERVICE-VERSION': '1.0.0',
        'SECURITY-APPNAME': EBAY_APP_KEY,
        'RESPONSE-DATA-FORMAT': 'JSON',
        'REST-PAYLOAD': '',
        'GLOBAL-ID': 'EBAY-US',
        'paginationInput.entriesPerPage': '50',
        ...req.query
    };


    // 生成查询字符串
    let queryString = new URLSearchParams(params).toString();

    console.log(queryString);

    const fullURL = baseURL + "?" + queryString;
    console.log("Constructed URL:", fullURL);


    // 请求eBay API并提取所需数据 
    try {
        const response = await axios.get(fullURL, {
            headers: {
                'Authorization': `Bearer ${EBAY_OAUTH_TOKEN}`,
                'Content-Type': 'application/json'
            },
            transformResponse: [data => data]
        });
        console.log("This is original data: " + response.data)
        const parsedData = JSON.parse(response.data);
        //console.log("This is parsed Data:" + parsedData)
        if (!parsedData.findItemsAdvancedResponse || parsedData.findItemsAdvancedResponse.length === 0) {
            console.error("No findItemsAdvancedResponse in the response");
            return;
        }

        const searchResult = parsedData.findItemsAdvancedResponse[0].searchResult;
        if (!searchResult || searchResult.length === 0 || !searchResult[0].item) {
            console.error("No items in the searchResult");
            res.json({ itemsFound: false }); // 返回一个标记了没有找到项的 JSON 对象
            return;
        }

        const items = searchResult[0].item;
        //console.log("This is items: ", items);
        //console.log("This is # of item we got: ", items.length);

        const extractedData = items.map(item => {
            // Initialize a helper function to safely extract nested properties
            const safeExtract = (nestedObj, pathArr) => {
                return pathArr.reduce((obj, key) =>
                    (obj && obj[key] != null) ? obj[key] : null, nestedObj);
            };

            // Extract data with safeExtract and check for undefined values
            const extractWithFallback = (pathArr, fallback = "not found") => {
                const value = safeExtract(item, pathArr);
                return value !== null ? value : fallback;
            };

            let shippingCostValue = extractWithFallback(['shippingInfo', '0', 'shippingServiceCost', '0', '__value__']);
            let shippingCost = shippingCostValue === "0.0" || shippingCostValue === "0" ? 'Free shipping' : `$ ${shippingCostValue}`;

            return {
                imageURL: extractWithFallback(['galleryURL', '0']),
                title: extractWithFallback(['title', '0']),
                price: extractWithFallback(['sellingStatus', '0', 'currentPrice', '0', '__value__']),
                postalCode: extractWithFallback(['postalCode', '0']),
                conditionDisplayName: extractWithFallback(['condition', '0', 'conditionDisplayName', '0']),
                shippingCost: shippingCost,
                shippingLocations: extractWithFallback(['shippingInfo', '0', 'shipToLocations', '0']),
                handlingTime: extractWithFallback(['shippingInfo', '0', 'handlingTime', '0']),
                expeditedShipping: extractWithFallback(['shippingInfo', '0', 'expeditedShipping', '0']),
                oneDayShipping: extractWithFallback(['shippingInfo', '0', 'oneDayShippingAvailable', '0']),
                returnsAccepted: extractWithFallback(['returnsAccepted', '0']),
                link: extractWithFallback(['viewItemURL', '0']),
                itemID: extractWithFallback(['itemId', '0']),
                categoryId: extractWithFallback(['primaryCategory', '0', 'categoryId', '0']),
                conditionId: extractWithFallback(['condition', '0', 'conditionId', '0'])
                // categoryName: extractWithFallback(['primaryCategory', '0', 'categoryName', '0']), // Uncomment if needed
            };
        });

        // Log the extracted data or errors if any field is missing
        extractedData.forEach((data, index) => {
            //console.log(`Item ${index + 1}:`, data);
            if (Object.values(data).some(value => value === "not found")) {
                console.error(`Data missing in item ${index + 1}`);
            }
        });
        //console.log("Extracted Data:", extractedData);
        
        const refinedData = extractedData.map(item => {
            return {
                title: item.title,
                itemID: item.itemID,
                shippingCost: item.shippingCost,  // 获取Shipping Cost
            };
        });
        //console.log("Refined Data:", refinedData);
        globalShippingExtractedData = refinedData;  // 仅存储精炼后的数据
        res.status(200).json(extractedData);
    } catch (error) {
        console.error("API call error:", error.response ? error.response.data : error.message);
        res.status(500).send(error.message);
    }

});

// 提供一个新的API端点来获取这个数据
app.get('/ebay/getStoredData', (req, res) => {
    res.status(200).json(globalShippingExtractedData);
});


// 获取单个商品详情的路由
app.get('/getSingleItem', async (req, res) => {
    const itemID = req.query.item_id;
    
    console.log(itemID)
    
    if (!itemID) {
        return res.status(400).send('Missing item_id parameter');
    }

    try {
        const itemData = await getSingleItem(itemID);
        
        let extractedData = {
            title: itemData.Item.Title,
            itemId: itemData.Item.ItemID || "not found",
            images: itemData.Item.PictureURL || "not found",
            price: (itemData.Item.CurrentPrice && itemData.Item.CurrentPrice.Value) ? itemData.Item.CurrentPrice.Value + " " + itemData.Item.CurrentPrice.CurrencyID : "not found",
            location: itemData.Item.Location || "not found",
            globalShipping: itemData.Item.GlobalShipping || "not found",
            handlingTime: itemData.Item.HandlingTime || "not found",
            returnPolicy: {
                ReturnsAccepted: itemData.Item.ReturnPolicy ? itemData.Item.ReturnPolicy.ReturnsAccepted : "not found",
                Refund: itemData.Item.ReturnPolicy ? itemData.Item.ReturnPolicy.Refund : "not found",
                ReturnsWithin: itemData.Item.ReturnPolicy ? itemData.Item.ReturnPolicy.ReturnsWithin : "not found",
                ShippingCostPaidBy: itemData.Item.ReturnPolicy ? itemData.Item.ReturnPolicy.ShippingCostPaidBy : "not found",
                   },
            feedbackRatingStar: itemData.Item.Seller.FeedbackRatingStar || "not found",
            feedbackScore: itemData.Item.Seller.FeedbackScore || "not found",
            positiveFeedbackPercent: itemData.Item.Seller.PositiveFeedbackPercent || "not found",
            topRatedSeller: itemData.Item.Seller.TopRatedSeller || "not found",
            storeURL: (itemData.Item.Storefront && itemData.Item.Storefront.StoreURL) ? itemData.Item.Storefront.StoreURL : "not found",
            storeName: (itemData.Item.Storefront && itemData.Item.Storefront.StoreName) ? itemData.Item.Storefront.StoreName : "not found",
            itemSpecifics: {}
        };

        // 提取ItemSpecifics中的NameValueList数组的值
        if (itemData.Item.ItemSpecifics && itemData.Item.ItemSpecifics.NameValueList) {
            itemData.Item.ItemSpecifics.NameValueList.forEach(spec => {
                extractedData.itemSpecifics[spec.Name] = spec.Value || "not found";
            });
        }
        
        console.log("Extracted Data:", extractedData);
        let refinedSellerData = {
            title: extractedData.title,
            feedbackRatingStar: extractedData.feedbackRatingStar,
            feedbackScore: extractedData.feedbackScore,
            positiveFeedbackPercent: extractedData.positiveFeedbackPercent,
            topRatedSeller: extractedData.topRatedSeller,
            storeURL: extractedData.storeURL,
            storeName: extractedData.storeName,
            globalShipping: extractedData.globalShipping,
            handlingTime: extractedData.handlingTime,
            ReturnsAccepted: extractedData.returnPolicy.ReturnsAccepted,
            Refund: extractedData.returnPolicy.Refund,
            ReturnsWithin: extractedData.returnPolicy.ReturnsWithin,
            ShippingCostPaidBy: extractedData.returnPolicy.ShippingCostPaidBy
            
        };
        
        console.log("Refined Seller Data:", refinedSellerData);
        globalSellerExtractedData = refinedSellerData;  // 仅存储精炼后的卖家数据
        res.status(200).json(extractedData);
    } catch (error) {
        console.error('Error fetching item details:', error);
        res.status(500).send('Failed to fetch item details');
    }
});

// 新的API端点来获取卖家数据
app.get('/ebay/getSellerData', (req, res) => {
    res.status(200).json(globalSellerExtractedData);  // 使用 globalSellerExtractedData 而不是 globalSellerData
});

// 请求单个商品数据的函数
async function getSingleItem(item_id) {
    const app_id = EBAY_APP_KEY;
    const endpoint = `https://open.api.ebay.com/shopping?callname=GetSingleItem&responseencoding=JSON&appid=${app_id}&siteid=0&version=967&ItemID=${item_id}&IncludeSelector=Details,ItemSpecifics`;

    try {
        const response = await axios.get(endpoint, {
            headers: {
                'X-EBAY-API-APP-ID': app_id,
                'X-EBAY-API-IAF-TOKEN': EBAY_OAUTH_TOKEN  // 使用这个 header 传递令牌
            }
        });
        
        console.log("Fetched Single Item Data:", JSON.stringify(response.data, null, 2));
        return response.data;  // 返回抓取的数据
    } catch (error) {
        console.error("Error fetching item:", error);
        throw error;  // 抛出错误，以便上层函数可以捕获
    }
}

// Google Images Search
app.get('/photos', async (req, res) => {
    const searchTerm = req.query.q;
    if (!searchTerm) {
        return res.status(400).json({ error: 'Query parameter "q" is required.' });
    }
    const googlePhotosUrl = `https://www.googleapis.com/customsearch/v1`;
    const params = {
        q: searchTerm,
        cx: GOOGLE_CSE_ID,
        imgSize: 'large',
        num: 8,
        searchType: 'image',
        key: GOOGLE_API_KEY
    };

    try {
        const response = await axios.get(googlePhotosUrl, { params });
        const photos = response.data.items.map(item => item.link);
        console.log(photos)
        res.status(200).json(photos);
    } catch (error) {
        console.error('Failed to fetch photos:', error);
        res.status(500).json({ error: 'Failed to fetch photos' });
    }
});

//getSimilarItem
// 获取相似商品的路由
app.get('/ebay/findSimilarItems', async (req, res) => {
    const itemID = req.query.itemId;
    console.log("this is ID:", itemID)
    if (!itemID) {
        return res.status(400).send('Missing item_id parameter');
    }

    try {
        const similarItemsData = await findSimilarItems(itemID);
        console.log("This is what I want: ",similarItemsData)
        // 提取所需的商品信息
        let extractedData = similarItemsData.getSimilarItemsResponse.itemRecommendations.item.map((item) => {
            // 提取剩余时间，例如P8DT4H51M40S 中的8天
            let timeMatch = item.timeLeft.match(/P(\d+)D/);
            let daysLeft = timeMatch ? timeMatch[1] : "Not specified"; // 如果匹配不到则返回"未指定"
            
            return {
                imageUrl: item.imageURL,
                productName: item.title,
                price: item.buyItNowPrice["__value__"], // 直接获取价格数值
                shippingCost: item.shippingCost ? item.shippingCost["__value__"] : 'Not Specified', // 直接获取运费数值
                daysLeft: daysLeft // 剩余天数
            };
        });

        console.log("Extracted Data:", extractedData);
        res.status(200).json(extractedData);
    } catch (error) {
        console.error('Error fetching similar items:', error);
        res.status(500).send('Failed to fetch similar items');
    }
});

// 请求相似商品数据的函数
async function findSimilarItems(item_id) {
    const app_id = EBAY_APP_KEY;
    const endpoint = `https://svcs.ebay.com/MerchandisingService?OPERATION-NAME=getSimilarItems&SERVICE-NAME=MerchandisingService&SERVICE-VERSION=1.1.0&CONSUMER-ID=${app_id}&RESPONSE-DATA-FORMAT=JSON&REST-PAYLOAD&itemId=${item_id}&maxResults=20`;

    try {
        const response = await axios.get(endpoint, {
            headers: {
                'X-EBAY-API-APP-ID': app_id,
                'Authorization': `Bearer ${EBAY_OAUTH_TOKEN}` // 使用这个 header 传递 OAuth 令牌
            }
        });

        console.log("Fetched Similar Items Data:", JSON.stringify(response.data, null, 2));
        return response.data;  // 返回获取的数据
    } catch (error) {
        console.error("Error fetching similar items:", error);
        throw error; 
    }
}

//连接mongoDB
//这里将双斜线 // URL编码为 %2F%2F
const password = encodeURIComponent("cyw974908339");
const uri = `mongodb+srv://caiyiweiusc:${password}@ebaywishlist.ofl2eqd.mongodb.net/myFirstDatabase?retryWrites=true&w=majority`;
const client = new MongoClient(uri, {
  useNewUrlParser: true,
  useUnifiedTopology: true,
  serverApi: {
    version: ServerApiVersion.v1,
    strict: true,
    deprecationErrors: true,
  }
});


let collection;
async function run() {
  try {
    await client.connect();
    console.log("Connected successfully to MongoDB");
    const db = client.db("myFirstDatabase");
    collection = db.collection("wishList");
  } catch (e) {
    console.error("Could not connect to MongoDB", e);
  } finally {
    process.on('SIGINT', async () => {
      await client.close();
      console.log('MongoDB client disconnected');
      process.exit(0);
    });
  }
}

run().catch(console.dir);

    // POST路由，用于保存item到数据库
app.post('/saveItem', async (req, res) => {
        try {
        const item = req.body;
        const result = await collection.insertOne(item);
        console.log(`A document was inserted with the _id: ${result.insertedId}`); // 输出插入文档的_id
        res.status(201).send(result);
        } catch (error) {
        console.error('Error saving item to database:', error);
        res.status(500).send(error);
        }
    });

  // DELETE 路由，用于从数据库中删除 item
app.post('/deleteItem', async (req, res) => {
        try {
        const itemID = req.body.itemID;
        console.log("console itemID need to be delete: " + itemID)
        const result = await collection.deleteOne({ itemID: itemID });
        if (result.deletedCount === 1) {
            console.log(`Document with itemID: ${itemID} was deleted`);
            res.status(200).send({ message: 'Item deleted successfully' });
        } else {
            res.status(404).send({ message: 'Item not found' });
        }
        } catch (error) {
        console.error('Error deleting item from database:', error);
        res.status(500).send(error);
        }
 });

    // GET 路由，用于从数据库获取 wish list 的所有数据
app.get('/getWishList', async (req, res) => {
        console.log("wishList is calling!");
        try {
        const collection = client.db("myFirstDatabase").collection("wishList");
        console.log('Retrieving wish list items from the database.');
        
        const items = await collection.find({}).toArray();
        console.log('Wish List Items retrieved:', items);
        res.setHeader('Content-Type', 'application/json');
        
        res.status(200).json(items);
        } catch (error) {
        console.error('Error retrieving wish list from database:', error);
        res.status(500).json({ message: "Internal Server Error" });
        }
    });

app.get('*', (req, res) => {
    res.sendFile(path.join(publicPath, 'index.html'));
  });
  
  const port = process.env.PORT || 4200;
  
app.listen(port, () => {
    fetchEbayOAuthToken(); // 启动服务器时获取eBay OAuth令牌
    console.log(`Server is running on port ${port}`);
  });
  
