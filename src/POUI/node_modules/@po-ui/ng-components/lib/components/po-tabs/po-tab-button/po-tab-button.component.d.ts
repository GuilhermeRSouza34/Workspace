import { ElementRef, EventEmitter, OnChanges, SimpleChanges } from '@angular/core';
import * as i0 from "@angular/core";
/**
 * @docsPrivate
 *
 * @description
 *
 * Componente responsável por manipular os botões de aba.
 */
export declare class PoTabButtonComponent implements OnChanges {
    private elementRef;
    disabled: boolean;
    id: string;
    label: string;
    small: boolean;
    activated: EventEmitter<any>;
    changeState: EventEmitter<any>;
    click: EventEmitter<any>;
    private _active;
    private _hide;
    set active(value: boolean);
    get active(): boolean;
    set hide(value: boolean);
    get hide(): boolean;
    constructor(elementRef: ElementRef);
    ngOnChanges(changes: SimpleChanges): void;
    onClick(): void;
    private emitActivated;
    private setDisplayOnHide;
    static ɵfac: i0.ɵɵFactoryDeclaration<PoTabButtonComponent, never>;
    static ɵcmp: i0.ɵɵComponentDeclaration<PoTabButtonComponent, "po-tab-button", never, { "disabled": "p-disabled"; "id": "p-id"; "label": "p-label"; "small": "p-small"; "active": "p-active"; "hide": "p-hide"; }, { "activated": "p-activated"; "changeState": "p-change-state"; "click": "p-click"; }, never, never, false>;
}
