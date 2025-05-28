import { EventEmitter } from '@angular/core';
import * as i0 from "@angular/core";
export declare class PoAccordionItemHeaderComponent {
    expanded: boolean;
    label: string;
    toggle: EventEmitter<boolean>;
    onClick(): void;
    static ɵfac: i0.ɵɵFactoryDeclaration<PoAccordionItemHeaderComponent, never>;
    static ɵcmp: i0.ɵɵComponentDeclaration<PoAccordionItemHeaderComponent, "po-accordion-item-header", never, { "expanded": "p-expanded"; "label": "p-label"; }, { "toggle": "p-toggle"; }, never, never, false>;
}
