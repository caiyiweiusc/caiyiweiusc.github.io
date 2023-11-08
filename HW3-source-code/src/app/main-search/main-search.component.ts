import { Component, OnInit, EventEmitter, Output, Input} from '@angular/core';
import { FormBuilder, FormGroup, Validators } from '@angular/forms';
import { HttpParams, HttpClient } from '@angular/common/http';
import { Router } from '@angular/router';



@Component({
  selector: 'app-main-search',
  templateUrl: './main-search.component.html',
  styleUrls: ['./main-search.component.css']
})
export class MainSearchComponent implements OnInit {
  @Output() backToResults = new EventEmitter<void>();
  @Input() item: any;  // 确保有这个Input装饰的属性
  searchForm!: FormGroup;
  conditions: number[] = [];
  items: any[] = [];  // 1. 定义一个属性来存储从服务器接收到的数据
  zipCodeOptions: string[] = [];
  wishListItems: any[] = [];
  isSearched = false; // 控制表格是否显示
  isZipEnabled = false;
  // 新增加的SearchComponent属性
  displayResults: boolean = true;
  displayWishList: boolean = false;
  // 定义 Set 来快速检查 Wishlist 中的 itemID
  private _wishlistItemIDs: Set<string> = new Set<string>();
  savedItemsMap: { [key: string]: boolean } = {}; 
  isLoading = false;

  constructor(private fb: FormBuilder, private http: HttpClient,private router: Router) { }
  

  ngOnInit(): void {
    this.initForm();
    this.onCurrentLocationSelected();
    this.items = [1]
  }

  // 新增加的SearchComponent方法
  showResults(): void {
      this.displayResults = true;
      this.displayWishList = false;
      // 这里可能需要一些逻辑来更新视图或类的其他部分
  }
  showWishList(): void {
      this.displayResults = false;
      this.displayWishList = true;
      this.getWishListItems();
      // 这里可能需要一些逻辑来更新视图或类的其他部分
  }

  // 在你的组件中添加属性来追踪活跃的按钮
  activeButton: 'results' | 'wishList' = 'results';

  // 方法来切换显示，并改变按钮的激活状态
  toggleDisplay(button: 'results' | 'wishList') {
     this.activeButton = button;
     this.displayResults = button === 'results';
     this.displayWishList = button === 'wishList';

     if (this.activeButton == 'wishList'){
        this.showWishList()
      }else if(this.activeButton == "results"){
        this.showResults()
      }
  }

  initForm() {
    this.searchForm = this.fb.group({
      keyword: ['', Validators.required],
      category: [''],
      distance: [''],
      zip: ['', [Validators.required, Validators.pattern(/^\d{5}$/)]]
    });
  }

  updateConditions(event: any) {
    const value = parseInt(event.target.value, 10);  // 确保 value 是数字

    if (event.target.checked) {
        if (!this.conditions.includes(value)) {
            this.conditions.push(value);
            console.log('Conditions:', this.conditions);
        }
    } else {
        const index = this.conditions.indexOf(value);
        if (index > -1) {
            this.conditions.splice(index, 1);
            
        }
    }
}


selectedCategory: number | null = null; // 类的属性，代表被选择的分类
  updateCategory(event: any) {
    this.selectedCategory = parseInt(event.target.value, 10);
    console.log(this.selectedCategory)
}

shippingOptions: { [key: string]: boolean } = {
  'local-pickup': false,
  'free-shipping': false
};

updateShippingOption(event: any, option: string) {
  this.shippingOptions[option] = event.target.checked;
  console.log('Shipping Options:', this.shippingOptions);
  
  // 根据复选框的选择，更新与eBay API相关的参数
  if (this.shippingOptions['local-pickup'] && !this.shippingOptions['free-shipping']) {
      // pass `LocalPickupOnly=true` to ebay api
  } else if (!this.shippingOptions['local-pickup'] && this.shippingOptions['free-shipping']) {
      // pass `FreeShippingOnly=true` to ebay api
  }
}


  onSubmit() {
    this.showResults()
    console.log(this.searchForm.value);
    this.searchForm.get('keyword')?.markAsTouched();
    this.searchForm.get('zip')?.markAsTouched();
    
    if (this.searchForm.valid) {
      const basicQueryParams = {
          'keywords': this.searchForm.get('keyword')?.value,
          'buyerPostalCode': this.searchForm.get('zip')?.value
      };
    
    const categoryValue = this.searchForm.get('category')?.value;
    let categoryParams = {};

    // 如果categoryValue不是'all'或者为空，则将其加入到categoryParams中
    if (categoryValue && categoryValue !== 'all') {
      categoryParams = {
        'categoryId': categoryValue
      };
    }

      // 为每个filter创建一个索引，始终从0开始
      let filterCounter = 0;

      // 创建一个对象来存储所有itemFilter参数
        let itemFilterParams: any = {};

      // 如果存在MaxDistance，将其添加为一个itemFilter
      const distanceValue = this.searchForm.get('distance')?.value;
      if (distanceValue) {
            itemFilterParams[`itemFilter(${filterCounter}).name`] = 'MaxDistance';
            itemFilterParams[`itemFilter(${filterCounter}).value`] = distanceValue;
            filterCounter++;  // 增加filter的索引
      }

      // 如果存在conditions，将其添加为一个itemFilter
      if (this.conditions.length > 0) {
            itemFilterParams[`itemFilter(${filterCounter}).name`] = 'Condition';
            this.conditions.forEach((condition, index) => {
                itemFilterParams[`itemFilter(${filterCounter}).value(${index})`] = condition;
            });
            filterCounter++;  // 增加filter的索引
      }

      // 处理 shippingOptions
      if (this.shippingOptions['local-pickup']) {
        itemFilterParams[`itemFilter(${filterCounter}).name`] = 'LocalPickupOnly';
        itemFilterParams[`itemFilter(${filterCounter}).value`] = true;
        filterCounter++;
      }

      if (this.shippingOptions['free-shipping']) {
        itemFilterParams[`itemFilter(${filterCounter}).name`] = 'FreeShippingOnly';
        itemFilterParams[`itemFilter(${filterCounter}).value`] = true;
        filterCounter++;
      }


      const finalQueryParams = { ...basicQueryParams, ...categoryParams, ...itemFilterParams}
      console.log('Final Query Params:', finalQueryParams);      
      this.isLoading = true;
      // 发送 HTTP 请求到 Node.js 服务器
      this.http.get('https://ebaysearch-hw3.wn.r.appspot.com/ebay/search', { params: new HttpParams({ fromObject: finalQueryParams }), responseType: 'text' })
      .subscribe(data => {
          console.log(data);
          try {
              const jsonData = JSON.parse(data);
              this.items = jsonData as any[];
               // 直接访问 itemID 属性并存储到一个数组中
              const itemIDs = jsonData.map((item: any) => item.itemID);
              console.log("This is all ItemsID:", itemIDs); // 打印所有 itemID，以便查看
              // 更新 this.items 中每个项目的 wishlist 状态
              this.items = jsonData;
              this.isLoading = false; // 当数据返回时，隐藏进度条
              this.checkItemsInWishlist(itemIDs);
              this.isSearched=true;
              
          } catch (error) {
              console.error('Error parsing JSON:', error);
          }
      }, error => {
          console.error('HTTP Error:', error);
          this.isSearched = true;
          this.items = [0]; // 发生错误时，设置 items 为空数组
          this.isLoading = false; // 即使出现错误，也需要隐藏进度条    
      });
    }
  }
  

  checkItemsInWishlist(itemIDs: string[]): void {
    // 使用 map 来更新 this.items 数组
    this.items = this.items.map((item) => {
      // 检查当前项目是否在愿望列表中
      const isInWishlist = this._wishlistItemIDs.has(item.itemID);
      // 如果项目在愿望列表中，记录到控制台，并设置 wishlist 属性
      if (isInWishlist) {
        console.log('We found them:', item.itemID);
      }
      // 返回更新了 wishlist 状态的项目对象
      return {
        ...item,
        wishlist: isInWishlist ? "true" : "false"
      };
    });
  
    // 打印带有 wishlist 状态的项目列表
    console.log('Updated items with wishlist status:', this.items);
  }
  

  wishlistItemIDs(): Set<string> {
    return this._wishlistItemIDs;
  }

  searchZipCodes(event: any): void {
  const query = event.target.value;
  console.log("This is event:", event);
  if (query && query.length >= 3) {
    this.http.get(`https://ebaysearch-hw3.wn.r.appspot.com/searchZipCodes`, { params: { postalcode_startsWith: query } })
      .subscribe(
        (data: any) => {
          console.log('Received data:', data);  // Log the received data to console
          if (data && data.postalCodes) {
            this.zipCodeOptions = data.postalCodes.map((code: any) => code.postalCode);
          } else {
            console.warn('Unexpected data format:', data);
          }
        },
        (error: any) => {
          console.error('Error fetching data:', error);  // Log the error to console if there's an issue with the HTTP request
        }
      );
  }
}

  getCurrentLocationZip() { 
    // 请确保您的端口号与Node.js服务器的端口号匹配
    this.http.get('https://ebaysearch-hw3.wn.r.appspot.com/getCurrentLocationZip').subscribe(
      (response: any) => {
        // 成功获取数据后的操作
        console.log(response.zip);
        // 如果你有表单或其他需要更新的地方，可以这样做：
        this.searchForm.patchValue({ zip: response.zip });
      },
      (error) => {
        // 错误处理
        console.error('Error fetching zip code:', error);
        }
      );
  }

  onCurrentLocationSelected() {
    // Disable zip input
    this.searchForm.controls['zip'].disable();
    this.isZipEnabled = false;
    
    // Fetch and set the current location zip code
    this.getCurrentLocationZip();
  }

  onOtherSelected() {
    // Enable zip input
    this.searchForm.controls['zip'].enable();
    this.isZipEnabled = true;

    // Clear the value of the zip form control
    this.searchForm.patchValue({ zip: '' });
  }

  clearFormAndSetLocation(): void {
    // 重置表单
    this.searchForm.reset();
    this.searchForm.markAsPristine();
    this.searchForm.markAsUntouched();

    // 设置表单为Current Location的状态
    this.onCurrentLocationSelected();

    // 清除搜索结果
    this.items = []; // 清空搜索结果数组
    this.isSearched = false; // 设置搜索状态为未搜索
    this.activeButton = 'results'; // 重置激活的按钮状态为结果
    }
  

  getWishListItems(): void {
    console.log("get wish list was called")
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
        console.error(error.message);
      }
    );
  }
  
}

