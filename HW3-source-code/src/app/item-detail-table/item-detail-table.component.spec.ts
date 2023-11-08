import { ComponentFixture, TestBed } from '@angular/core/testing';

import { ItemDetailTableComponent } from './item-detail-table.component';

describe('ItemDetailTableComponent', () => {
  let component: ItemDetailTableComponent;
  let fixture: ComponentFixture<ItemDetailTableComponent>;

  beforeEach(() => {
    TestBed.configureTestingModule({
      declarations: [ItemDetailTableComponent]
    });
    fixture = TestBed.createComponent(ItemDetailTableComponent);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
