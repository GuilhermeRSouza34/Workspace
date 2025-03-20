import { AfterContentInit, ElementRef } from '@angular/core';
import { PoTabBaseComponent } from './po-tab-base.component';
import * as i0 from "@angular/core";
/**
 * @docsExtends PoTabBaseComponent
 */
export declare class PoTabComponent extends PoTabBaseComponent implements AfterContentInit {
    private elementRef;
    constructor(elementRef: ElementRef);
    ngAfterContentInit(): void;
    protected setDisplayOnActive(): void;
    static ɵfac: i0.ɵɵFactoryDeclaration<PoTabComponent, never>;
    static ɵcmp: i0.ɵɵComponentDeclaration<PoTabComponent, "po-tab", never, {}, {}, never, ["*"], false>;
}
