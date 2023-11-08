import { Component, OnInit, Input, ViewEncapsulation } from '@angular/core';

@Component({
  selector: 'shipping-tab',
  templateUrl: './shipping-tab.component.html',
  styleUrls: ['./shipping-tab.component.css'],
  encapsulation: ViewEncapsulation.None
})
export class ShippingTabComponent implements OnInit {
  @Input() shippingInfo: any;  // 使用 @Input 装饰器来接收数据

  ngOnInit(): void {
  }

  objectKeys(obj: any): string[] {
    return Object.keys(obj);
  }
  
  formatKey(key: string): string {
    return key.charAt(0).toUpperCase() + key.slice(1).replace(/([A-Z])/g, ' $1').trim();
  }

  formatValue(key: string, value: any): any {
    if (key === 'shippingCost' && value === '0.0') {
      return 'Free Shipping';
    }
    if (key === 'handlingTime') {
      return `${value} Days`;
    }
    // 当为布尔值且为true时，返回Bootstrap的勾勾图标
    if (value === true || value === 'true') {
      return '<span class="material-icons green-icon">done</span>';
    } else if (value === false || value === 'not found' || value === 'false') {
      return '<span class="material-icons red-icon">clear</span>';  // 'clear' 是 Material Icons 中表示 "cross" 的图标
    }
    return value;
  }
}

