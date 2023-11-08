import { ComponentFixture, TestBed } from '@angular/core/testing';

import { PhotoTabComponent } from './photo-tab.component';

describe('PhotoTabComponent', () => {
  let component: PhotoTabComponent;
  let fixture: ComponentFixture<PhotoTabComponent>;

  beforeEach(() => {
    TestBed.configureTestingModule({
      declarations: [PhotoTabComponent]
    });
    fixture = TestBed.createComponent(PhotoTabComponent);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
