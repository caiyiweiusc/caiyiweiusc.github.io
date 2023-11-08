import { Component, OnInit, Input, OnChanges, SimpleChanges, Output, EventEmitter} from '@angular/core';
import { HttpClient } from '@angular/common/http';  // <-- 导入HttpClient

@Component({
  selector: 'app-items-list-table',
  templateUrl: './items-list-table.component.html',
  styleUrls: ['./items-list-table.component.css']
})
export class ItemsListTableComponent implements OnInit {
  @Input() items!: any[];  // 从主组件接收的项目列表
  @Input() isSearched = false;  // 控制表格是否显示
  @Output() itemSelected: EventEmitter<any> = new EventEmitter();  // <-- 新增这一行
  showItemList: boolean = true; 
  selectedItem: any = null;
  currentPage = 1;
  itemsPerPage = 10;
  wishListItems: any[] = [];
  savedItems: { [key: string]: boolean } = {};
  isLoadingItemDetails: boolean = false;
  private _wishlistItemIDs: Set<string> = new Set<string>();
  constructor(private http: HttpClient) { }  // <-- 注入HttpClient

  ngOnInit(): void {
    this.checkWishlistStatus();
  }
  ngOnChanges(changes: SimpleChanges): void {
    // 当items输入属性发生变化时，调用checkWishlistStatus
    if (changes['items'] && changes['items'].currentValue) {
      this.checkWishlistStatus();
    }
  
    // 当isSearched输入属性变为true时，也调用checkWishlistStatus
    if (changes['isSearched'] && changes['isSearched'].currentValue === true) {
      this.checkWishlistStatus();
    }
  }

    // 这个方法将用来截断字符串
  truncateTitle(title: string, maxLength: number = 35): string {
      if (title.length > maxLength) {
        return title.substring(0, maxLength) + '...';
      } else {
        return title;
      }
  }

  // 在主组件的搜索函数中被调用，用来显示表格
  onSearch(): void {
    this.isSearched = true;
  }

  // 翻页功能
  getDisplayedItems(): any[] {
    const start = (this.currentPage - 1) * this.itemsPerPage;
    const end = this.currentPage * this.itemsPerPage;
    const items = this.items.slice(start, end).map(item => {
      // 使用truncateTitle方法来截断title
      return {
        ...item,
        title: this.truncateTitle(item.title)
      };
    });
    return items;
  }

  // 计算总页数的函数
  getTotalPages(): number {
    return Math.ceil(this.items.length / this.itemsPerPage);
  }

  getItemDetails(itemID: string): void {
    this.isLoadingItemDetails = true; // 隐藏进度条
    const serverEndpoint = `https://ebaysearch-hw3.wn.r.appspot.com/getSingleItem?item_id=${itemID}`;
    this.http.get(serverEndpoint).subscribe(
      (data) => {
        this.itemSelected.emit(data);  // 发射事件和数据\
        this.selectedItem = data;
        this.showItemList = false;  // 添加这一行
        this.isLoadingItemDetails = false; // 隐藏进度条
        console.log("itemlist status:", this.showItemList)
      },
      (error) => {
        console.error('Error fetching item details:', error);
        this.isLoadingItemDetails = false; // 隐藏进度条
      }
    );
  }

  // 返回到item list
  backToList(): void {
    this.showItemList = true;
    this.selectedItem = null; // 清空已选择的item
  }

  // wishListButton
  toggleItemInDatabase(item: any): void {
    // 如果项目已保存，则执行删除操作，否则保存项目
    if (this.isItemInWishlist(item.itemID)) {
      this.deleteItemFromDatabase(item.itemID);
    } else {
      this.saveItemToDatabase(item);
    }
  }

  saveItemToDatabase(item: any): void {

    // 创建一个新对象，只包含需要的字段
    const itemToSave = {
      itemID: item.itemID,
      imageURL: item.imageURL,
      title: item.title,
      price: item.price,
      shippingCost: item.shippingCost
    };

    console.log("This is about this item:", itemToSave);

    const serverEndpoint = 'https://ebaysearch-hw3.wn.r.appspot.com/saveItem';
    this.http.post(serverEndpoint, itemToSave).subscribe(
      () => {
        console.log('Item saved to database!');
        // 这里你可以添加一些UI反馈，比如弹窗提示
        this.savedItems[item.itemID] = true;
        this._wishlistItemIDs.add(item.itemID);
      },
      (error) => {
        console.error('Error saving item to database:', error);
      }
    );
  }

    // 从数据库中删除项目的方法
  private deleteItemFromDatabase(itemID: string): void {
      const serverEndpoint = 'https://ebaysearch-hw3.wn.r.appspot.com/deleteItem';
      this.http.post(serverEndpoint, { itemID }).subscribe(
        () => {
          console.log('Item deleted from database!');
          this.savedItems[itemID] = false; // 标记为未保存
          this._wishlistItemIDs.delete(itemID);
        },
        (error) => {
          console.error('Error deleting item from database:', error);
        }
      );
    } 

    // 这个方法检查一个itemID是否在愿望清单的Set中
  isItemInWishlist(itemID: string): boolean {
    return this._wishlistItemIDs.has(itemID);
  }
    
  wishlistItemIDs(): Set<string> {
      return this._wishlistItemIDs;
    }

      // 新增加的函数，用于检查wishlist的状态
  private checkWishlistStatus(): void {
    this.http.get<any[]>('https://ebaysearch-hw3.wn.r.appspot.com/getWishList').subscribe(
      data => {
        console.log('Wish List Items:', data);
        // 如果需要在视图中展示，可以将数据赋值给一个变量
        this.wishListItems = data; // 将数据存储到 wishListItems 属性中
        this._wishlistItemIDs.clear();
        // 遍历数据并填充itemID到_set中
        data.forEach(item => {
          if (item.itemID) {
            this._wishlistItemIDs.add(item.itemID);
            console.log("This is current Wishlist IDs:", this.wishlistItemIDs);
          }
        })
      },
      error => {
        console.error('Error fetching wish list items:', error);
      }
    );
  }

}

