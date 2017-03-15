import { AbstractOrderItemDecorator } from 'decorators';
import { OrderItem } from 'models';

export class OrderItemDecorator extends AbstractOrderItemDecorator {
    public isActive: boolean = false;
    public isFocused: boolean = false;

    constructor(orderItem: OrderItem) { super(orderItem); }
}