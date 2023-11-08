import { NgModule } from '@angular/core';
import { BrowserModule } from '@angular/platform-browser';
import { AppRoutingModule } from './app-routing.module';
import { AppComponent } from './app.component';
import { BrowserAnimationsModule } from '@angular/platform-browser/animations';
import { MatSlideToggleModule } from '@angular/material/slide-toggle';
import { MainSearchComponent } from './main-search/main-search.component';
import { ReactiveFormsModule } from '@angular/forms';
import { HttpClientModule } from '@angular/common/http';
import { ItemsListTableComponent } from './items-list-table/items-list-table.component';
import { ItemDetailTableComponent } from './item-detail-table/item-detail-table.component';
import { MatAutocompleteModule } from '@angular/material/autocomplete';
import { MatInputModule } from '@angular/material/input';
import { PhotoTabComponent } from './photo-tab/photo-tab.component';
import { ShippingTabComponent } from './shipping-tab/shipping-tab.component';
import { SellerTabComponent } from './seller-tab/seller-tab.component';
import {MatIconModule} from '@angular/material/icon';
import {RoundProgressModule} from 'angular-svg-round-progressbar';
import { SimilarProductsTabComponent } from './similar-products-tab/similar-products-tab.component';
import { FormsModule } from '@angular/forms';
import { WishListComponent } from './wish-list/wish-list.component';
import { NoRecordsComponent } from './no-records/no-records.component';





@NgModule({
  declarations: [
    AppComponent,
    MainSearchComponent,
    ItemsListTableComponent,
    ItemDetailTableComponent,
    PhotoTabComponent,
    ShippingTabComponent,
    SellerTabComponent,
    SimilarProductsTabComponent,
    WishListComponent,
    NoRecordsComponent,

    
  ],
  imports: [
    BrowserModule,
    AppRoutingModule,
    BrowserAnimationsModule,
    MatSlideToggleModule,
    ReactiveFormsModule,
    HttpClientModule,
    MatAutocompleteModule,
    MatInputModule,
    MatIconModule,
    [RoundProgressModule],
    FormsModule,
  ],
  providers: [],
  bootstrap: [AppComponent]
})

export class AppModule { }


