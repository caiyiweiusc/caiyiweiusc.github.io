import { ComponentFixture, TestBed } from '@angular/core/testing';

import { ItemsListTableComponent } from './items-list-table.component';

describe('ItemsListTableComponent', () => {
  let component: ItemsListTableComponent;
  let fixture: ComponentFixture<ItemsListTableComponent>;

  beforeEach(() => {
    TestBed.configureTestingModule({
      declarations: [ItemsListTableComponent]
    });
    fixture = TestBed.createComponent(ItemsListTableComponent);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
