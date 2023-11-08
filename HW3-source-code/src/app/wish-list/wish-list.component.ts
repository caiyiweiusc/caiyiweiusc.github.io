import { Component, Input, Output, EventEmitter } from '@angular/core';
import { HttpClient } from '@angular/common/http'; // 导入HttpClient

@Component({
  selector: 'app-wish-list',
  templateUrl: './wish-list.component.html',
  styleUrls: ['./wish-list.component.css']
})
export class WishListComponent {
  @Input() items: any[] = []; // 接收从父组件传递的愿望列表数据
  @Output() itemRemoved = new EventEmitter<number>();

  constructor(private http: HttpClient) {} // 注入HttpClient服务

  // 删除条目的方法
  removeFromWishList(itemId: number) {
    this.deleteItemFromDatabase(itemId.toString()); // 注意，这里假设itemId是数字类型
  }

  // 从数据库中删除项目的方法
  private deleteItemFromDatabase(itemID: string): void {
    const serverEndpoint = 'https://ebaysearch-hw3.wn.r.appspot.com/deleteItem';
    this.http.post(serverEndpoint, { itemID }).subscribe(
      () => {
        console.log('Item deleted from database!');
        // 在这里更新组件的items数组，移除已删除的item
        this.items = this.items.filter(item => item.itemID !== itemID);
        // 发出事件，可能需要传递更多信息来确定哪个项目被删除
        this.itemRemoved.emit(Number(itemID));
      },
      (error) => {
        console.error('Error deleting item from database:', error);
      }
    );   
  }

    // 获取总价格（不包含运费）
      // 获取总价格（不包含运费）
    getTotalPrice(): number {
      return this.items.reduce((total, item) => {
        // 将价格字符串转换为浮点数并累加
        const price = parseFloat(item.price);
        // 确保转换结果是一个有效的数字
        return total + (isNaN(price) ? 0 : price);
      }, 0);
    }
}