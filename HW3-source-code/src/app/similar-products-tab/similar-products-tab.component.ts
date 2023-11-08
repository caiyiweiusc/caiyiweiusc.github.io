import { Component, Input, OnInit, SimpleChanges, OnChanges } from '@angular/core';

@Component({
  selector: 'app-similar-products-tab',
  templateUrl: './similar-products-tab.component.html',
  styleUrls: ['./similar-products-tab.component.css']
})
export class SimilarProductsTabComponent implements OnInit, OnChanges {
  @Input() similarItems!: any[]; 
  selectedSortField: string = 'default'; 
  sortDirection: string = 'asc'; 
  sortedItems: any[] = [];
  isShowMore: boolean = false; // 新增状态变量

  // 新增方法
  toggleShowMore() {
    this.isShowMore = !this.isShowMore; // 切换展示状态
    this.sortedItems = this.isShowMore ? this.similarItems : this.similarItems.slice(0, 5);
  }

  ngOnChanges(changes: SimpleChanges): void {
    if (changes['similarItems'] && changes['similarItems'].currentValue) {
      console.log('Similar items updated:', this.similarItems);
      // 只有在'isShowMore'为true时才展示全部items，否则展示前5个
      this.sortedItems = this.isShowMore ? [...this.similarItems] : [...this.similarItems].slice(0, 5);
    }
  }

  ngOnInit(): void {
    // 初始时只展示前5个items
    this.sortedItems = this.similarItems.slice(0, 5);
  }

  sortItems() {
    if (this.selectedSortField === 'default') {
        this.sortedItems = [...this.similarItems];
    } else {
        this.sortedItems.sort((a, b) => {
            let aValue = a[this.selectedSortField];
            let bValue = b[this.selectedSortField];

            // 如果是数字字符串，则转换为数字
            if (['price', 'shippingCost', 'daysLeft'].includes(this.selectedSortField)) {
                aValue = parseFloat(aValue);
                bValue = parseFloat(bValue);
            }

            if (aValue < bValue) {
                return this.sortDirection === 'asc' ? -1 : 1;
            }
            if (aValue > bValue) {
                return this.sortDirection === 'asc' ? 1 : -1;
            }
            return 0;
        });
    }
}

}
