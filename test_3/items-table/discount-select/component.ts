import { Component, Input, OnInit} from '@angular/core';
import { OrderUpdateService } from '../../../order-update.service';
import { DiscountRepositoryService } from 'repositories';
import { DiscountType } from 'enums';
import { Discount, OrderItem } from 'models';
import { SelectOption } from 'helpers';
import { FormControl } from '@angular/forms';
import * as _ from 'lodash';

@Component({
  selector: 'pp-orders-show-shared-items-table-discount-select',
  templateUrl: './template.pug'
})

export class OrdersShowSharedItemsTableDiscountSelectComponent implements OnInit {

  @Input() orderItem: OrderItem;
  @Input() isActive: boolean = false;

  private discounts: Array<SelectOption<Discount>> = [];
  private selectedDiscount: FormControl = new FormControl();

  constructor(private ordersUpdateService: OrderUpdateService, private discountRepo: DiscountRepositoryService) {}

  public ngOnInit() {
    if (!this.isActive) { this.selectedDiscount.disable(); }
    this.loadDiscounts();
  }

  private loadDiscounts(): void {
    this.discountRepo.index().subscribe((discounts) => {
      this.discounts = _.map(discounts, (discount) => {
        let selected = false;
        if (this.orderItem.discount && this.orderItem.discount.id == discount.id) {
          this.selectedDiscount.setValue(discount);
          selected = true;
        }
        return new SelectOption(discount, discount.name, selected);
      });
    });
  }

  private onDiscountSelected(event): void {
    this.orderItem.discount_id = this.selectedDiscount.value.id;
    this.ordersUpdateService.setDiscount(this.orderItem);
  }

}