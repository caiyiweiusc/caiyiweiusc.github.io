import { Component, OnInit, Input, Output, EventEmitter } from '@angular/core';
import { HttpClient } from '@angular/common/http';

@Component({
  selector: 'app-item-detail-table',
  templateUrl: './item-detail-table.component.html',
  styleUrls: ['./item-detail-table.component.css']
})
export class ItemDetailTableComponent implements OnInit {
  @Output() backToList: EventEmitter<void> = new EventEmitter();
  public shippingInfo: any;  // 新增这一行来存储当前 item 的 shipping 信息
  public sellerInfo: any;  // 用来存储当前 item 的 seller 信息
  public similarItems: any; // 添加这一行来存储从服务器获取的相似项目数据
  activeTab: string = 'product'; // 只定义一次 currentTab，设定初始值为 'product'

  @Input() shipping!: {
    shippingCost: string;
    shippingLocations: string;
    handlingTime: string;
    expeditedShipping: string;
    oneDayShipping: string;
    returnsAccepted: string;
  };

  @Input() item!: {
    title?: string;
    images: string[];
    price: string;
    location: string;
    returnPolicy: string;
    itemSpecifics: {
      [key: string]: string[];
    };
  };

  showDetails: boolean = false;

  myData: any; // 添加这一行来存储从 Node.js 服务器获取的数据

  constructor(private http: HttpClient) {} // 注入 HttpClient

  ngOnInit(): void {
    if (!this.item || Object.keys(this.item).length === 0) {
      console.error('No data received for item!');
    } else {
      console.log('Received item data:', this.item);
      this.displayItemDetails(this.item);
    }
  }

  getObjectKeys(obj: { [key: string]: any }): string[] {
    return Object.keys(obj);
  }

  displayItemDetails(details: any): void {
    this.item = details;
    this.showDetails = true;
  }

  changeTab(tabName: string): void {
    this.activeTab = tabName;

    // 当 tabName 是 'photo' 时，从服务器获取数据并调用 Google API
    if (tabName === 'photo' && this.item?.title) {
      // 使用 item 的 title 调用后端 /photos 端点，该端点将请求转发给 Google API
      this.http.get(`https://ebaysearch-hw3.wn.r.appspot.com/photos?q=${encodeURIComponent(this.item.title)}`).subscribe(
        googleData => {
          console.log('Data received from Google API:', googleData);
          this.item.images = <string[]>googleData;
          // 在这里可以进一步处理从 Google API 返回的图片数据
        },
        error => {
          console.error('Error while calling the /photos endpoint on the backend!', error);
        }
      );
    }

  
    // 当 tabName 是 'shipping' 时，从服务器获取数据
    if (tabName === 'shipping') {
      this.http.get('https://ebaysearch-hw3.wn.r.appspot.com/ebay/getStoredData').subscribe(
        data => {
          this.myData = data as any[];
          console.log('Received data from Node.js server:', this.myData);
  
          // 获取当前 item 的 itemID
          const currentItemId = (this.item as any).itemId;
  
          // 在 myData 中查找与当前 itemID 匹配的 shipping 信息
          const shippingInfo = this.myData.find((item: any) => item.itemID === currentItemId);
          if (shippingInfo) {
            delete shippingInfo.itemID;  // 删除 itemID 属性
            console.log('Shipping info for current item:', shippingInfo);
            this.shippingInfo = shippingInfo;  // 添加这一行
            // 如果需要，你可以在这里进一步处理 shippingInfo
          } else {
            console.log('No shipping info found for current item.');
          }
  
        },
        error => {
          console.error('There was an error!', error);
        }
      );
    }
    if (tabName === 'seller') {
      this.http.get('https://ebaysearch-hw3.wn.r.appspot.com/ebay/getSellerData').subscribe(
          data => {
              this.sellerInfo = data as any[];
              console.log('Received seller data from Node.js server:', this.sellerInfo);
          },
          error => {
              console.error('There was an error!', error);
          }
      );
   }

     // 当 tabName 是 'similar' 时，从服务器获取相似项目的数据
    if (tabName === 'similar') {
      // 获取当前 item 的 itemId
      const currentItemId = (this.item as any).itemId;
      console.log("This is ID in TS:", currentItemId)
      // 使用 itemId 调用后端 /similar-items 端点，该端点将请求转发给相应的服务以获取相似项数据
      this.http.get(`https://ebaysearch-hw3.wn.r.appspot.com/ebay/findSimilarItems?itemId=${encodeURIComponent(currentItemId)}`).subscribe(
        similarItemsData => {
          console.log('Data received for similar items:', similarItemsData);
          this.similarItems = similarItemsData as any[]; // 假设 similarItems 是组件的一个属性
          // 在这里可以进一步处理从后端返回的相似项目数据
        },
        error => {
          console.error('Error while calling the /similar-items endpoint on the backend!', error);
        }
      );
    }
  
  }
  
}
