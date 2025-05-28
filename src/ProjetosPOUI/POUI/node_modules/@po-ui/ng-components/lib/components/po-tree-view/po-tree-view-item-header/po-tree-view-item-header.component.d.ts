import { EventEmitter } from '@angular/core';
import { PoTreeViewItem } from '../po-tree-view-item/po-tree-view-item.interface';
import * as i0 from "@angular/core";
export declare class PoTreeViewItemHeaderComponent {
    inputCheckbox: any;
    item: PoTreeViewItem;
    selectable: boolean;
    expanded: EventEmitter<MouseEvent>;
    selected: EventEmitter<any>;
    get hasSubItems(): boolean;
    static ɵfac: i0.ɵɵFactoryDeclaration<PoTreeViewItemHeaderComponent, never>;
    static ɵcmp: i0.ɵɵComponentDeclaration<PoTreeViewItemHeaderComponent, "po-tree-view-item-header", never, { "item": "p-item"; "selectable": "p-selectable"; }, { "expanded": "p-expanded"; "selected": "p-selected"; }, never, never, false>;
}
