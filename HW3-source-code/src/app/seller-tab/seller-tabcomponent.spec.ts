import { ComponentFixture, TestBed } from '@angular/core/testing';

import { SellerTapComponent } from './seller-tab.component';

describe('SellerTapComponent', () => {
  let component: SellerTapComponent;
  let fixture: ComponentFixture<SellerTapComponent>;

  beforeEach(() => {
    TestBed.configureTestingModule({
      declarations: [SellerTapComponent]
    });
    fixture = TestBed.createComponent(SellerTapComponent);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
