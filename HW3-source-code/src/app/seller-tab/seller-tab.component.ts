import { Component, Input, ViewEncapsulation  } from '@angular/core';

@Component({
  selector: 'seller-tab',
  templateUrl: './seller-tab.component.html',
  styleUrls: ['./seller-tab.component.css'],
  encapsulation: ViewEncapsulation.None
})
export class SellerTabComponent {
  @Input() sellerInfo: any;
  
  displayValue(key: string, value: any): any {
    // 为 topRatedSeller 进行判断
    if (key === 'topRatedSeller') {
      if (value === true) {
          return '<span class="material-icons green-icon">done</span>';
      } else if (value === false || value === "not found") {
          return '<span class="material-icons red-icon">clear</span>';  // 'clear' 是 Material Icons 中表示 "cross" 的图标
      }
    }

    // 为 feedbackRatingStar 进行判断
    if (key === 'feedbackRatingStar') {
      const colors = ['Yellow', 'Blue', 'Turquoise', 'Purple', 'Red', 'Green', 'Silver'];
      let matchedColor = null;

      for (const color of colors) {
          if (value.includes(color)) {
              matchedColor = color.toLowerCase();
              break;
          }
      }

      if (matchedColor) {
          if (value.includes('Shooting')) {
              return `<span class="material-icons ${matchedColor}-star">stars</span>`;
          } else {
              return `<span class="material-icons ${matchedColor}-star">star_border</span>`;
          }
      } else {
          return '<span class="material-icons">star_border</span>';
      }
    }
    return value;  // 默认返回原值
  }
  

  
}
