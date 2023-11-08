import { Component, Input, OnInit } from '@angular/core';

@Component({
  selector: 'photo-tab',
  templateUrl: './photo-tab.component.html',
  styleUrls: ['./photo-tab.component.css']
})
export class PhotoTabComponent {
  @Input() images!: string[];

  constructor() { }

}


