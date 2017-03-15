import { Component, OnInit, Input, ElementRef} from '@angular/core';
import { Order, OrderItem } from 'models';
import { OrderItemDecorator } from './order-item.decorator';
import { OrderUpdateService } from '../../order-update.service';
import { DomHelper } from 'helpers';
import * as _ from 'lodash';

@Component({
  selector: 'pp-orders-show-shared-items-table',
  styleUrls: ['./styles/_import.sass'],
  templateUrl: './template.pug',
  host: {
    '(document:click)': 'handleDocumentClick($event)',
    '(document:keydown)': 'handleDocumentKeydown($event)',
  },
})

export class OrdersShowSharedItemsTableComponent implements OnInit {
  private order: Order;
  private orderItems: OrderItemDecorator[];
  private activeOrderItemId: number = null;
  private isItemTableActive: boolean = false;
  @Input() isNavigationDisabled: boolean = false;
  @Input() showDiscount: boolean = true;

  constructor(private ordersUpdateService: OrderUpdateService, private componentRef: ElementRef) {}

  ngOnInit() {
    this.initOrderItemTableData(this.ordersUpdateService.getCurrentOrder());
    this.ordersUpdateService.onOrderUpdated.subscribe( order  => this.initOrderItemTableData(order) );
  }

  private initOrderItemTableData(order: Order) {
      this.order = order;
      this.orderItems = _.map(this.order.order_items, item => new OrderItemDecorator(item));
      this.inactivateOrderItemsExcept(this.activeOrderItemId);
  }

  private onOrderItemCountInputChange(orderItem: OrderItemDecorator, event) {
    let count = parseInt(event.target.value);
    if (!this.updateOrderItemCount(orderItem, count)) {
      event.target.value = orderItem.count;
    }
  }

  private preventClickEvent(event) {
    event.stopPropagation();
  }

  private deleteOrderItem(orderItem: OrderItem) {
    if (confirm(`Are you sure to delete ${orderItem.title}`)) {
      this.ordersUpdateService.removeItem(orderItem);
    }
  }

  private clearOrderCart() {
    if (confirm('Are you sure to delete all items in order')) {
      this.ordersUpdateService.clearCart();
    }
  }

  private handleDocumentClick(event) {
    if (this.isNavigationDisabled) { return null; };
    event.stopPropagation();
    if (!DomHelper.elementInsideComponent(event.target, this.componentRef.nativeElement.nodeName)) {
      this.isItemTableActive = false;
      this.activeOrderItemId = null;
      this.orderItems = _.map(this.orderItems, (item) => { item.isActive = false; return item; });
    } else {
      this.isItemTableActive = true;
    }
  }
  private handleDocumentKeydown(event) {
    if (this.isNavigationDisabled) { return null; };
    if (!!this.isItemTableActive) {
      let activeOrderItem = _.find(this.orderItems, { isActive: true });
      if (!activeOrderItem) { return null; };
      event.preventDefault();
      switch (event.key) {
        case 'Delete':
          this.deleteOrderItem(activeOrderItem);
          break;
        case 'ArrowLeft':
        case '-':
          this.updateOrderItemCount(activeOrderItem, activeOrderItem.count - 1);
          break;
        case '+':
        case 'ArrowRight':
          this.updateOrderItemCount(activeOrderItem, activeOrderItem.count + 1);
          break;
        case 'ArrowUp':
          this.navigateOrderItems(activeOrderItem, -1);
          break;
        case 'ArrowDown':
          this.navigateOrderItems(activeOrderItem, 1);
          break;
        default:
           break;
      }
    }
  }

  private toggleOrderItemActive(orderItem: OrderItemDecorator) {
    if (this.isNavigationDisabled) { return null; };
    orderItem.isActive = !orderItem.isActive;
    if (orderItem.isActive) {
      this.inactivateOrderItemsExcept(orderItem.id);
    } else {
      this.inactivateAllOrderItems();
    }
  }

  private navigateOrderItems(activeOrderItem: OrderItem, delta: number) {
    let currentIndex = _.findIndex(this.orderItems, activeOrderItem)
    let maxIndex = this.orderItems.length - 1;
    let newIndex = currentIndex + delta;
    let newActiveOrderItem: OrderItem;

    _.forEach(this.orderItems, item => item.isActive = false );
    if (newIndex == -1) {
      newActiveOrderItem = this.orderItems[maxIndex]
    } else if (newIndex > maxIndex) {
      newActiveOrderItem = this.orderItems[0]
    } else {
      newActiveOrderItem = this.orderItems[newIndex]
    }
    this.inactivateOrderItemsExcept(newActiveOrderItem.id);
  }

  private updateOrderItemCount(orderItem: OrderItem, count: number): boolean {
    if (!!count && count >= 1 && count <= 99) {
      orderItem.count = count;
      this.ordersUpdateService.updateItem(orderItem);
      return true;
    } else {
      return false;
    }
  }

  private inactivateOrderItemsExcept(orderItemId: number) {
    if (this.isNavigationDisabled) { return null; };
    this.activeOrderItemId = orderItemId;
    this.inactivateAllOrderItems();
    if (!!this.activeOrderItemId) {
      let activeOrderItem = _.find(this.orderItems, {id: this.activeOrderItemId})
      if (!!activeOrderItem) { activeOrderItem.isActive = true };
    }
  }

  private inactivateAllOrderItems() {
    this.orderItems = _.map(this.orderItems, (item) => { item.isActive = false; return item;} )
  }
}