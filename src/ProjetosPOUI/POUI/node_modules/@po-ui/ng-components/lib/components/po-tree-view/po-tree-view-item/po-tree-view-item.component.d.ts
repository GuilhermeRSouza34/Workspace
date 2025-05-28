import { PoTreeViewItem } from './po-tree-view-item.interface';
import { PoTreeViewService } from '../services/po-tree-view.service';
import * as i0 from "@angular/core";
export declare class PoTreeViewItemComponent {
    private treeViewService;
    item: PoTreeViewItem;
    selectable: boolean;
    get hasSubItems(): boolean;
    constructor(treeViewService: PoTreeViewService);
    onClick(event: MouseEvent): void;
    onSelect(selectedItem: PoTreeViewItem): void;
    trackByFunction(index: number): number;
    static ɵfac: i0.ɵɵFactoryDeclaration<PoTreeViewItemComponent, never>;
    static ɵcmp: i0.ɵɵComponentDeclaration<PoTreeViewItemComponent, "po-tree-view-item", never, { "item": "p-item"; "selectable": "p-selectable"; }, {}, never, never, false>;
}
