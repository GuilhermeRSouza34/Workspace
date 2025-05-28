import { ElementRef, EventEmitter } from '@angular/core';
import { PoPopoverComponent } from '../../po-popover/po-popover.component';
import { PoTabComponent } from '../po-tab/po-tab.component';
import * as i0 from "@angular/core";
/**
 * @docsPrivate
 *
 * @description
 *
 * Componente para agrupamento de componentes `po-tab-button` que os rendereiza em uma um caixa de diálogo
 * no formato de lista.
 */
export declare class PoTabDropdownComponent {
    popover: PoPopoverComponent;
    tabDropdown: ElementRef;
    label: string;
    small: boolean;
    tabs: Array<PoTabComponent>;
    activated: EventEmitter<any>;
    changeState: EventEmitter<any>;
    click: EventEmitter<any>;
    getContainerClass(): "po-tab-dropdown-container-sm" | "po-tab-dropdown-container";
    togglePopover(): void;
    static ɵfac: i0.ɵɵFactoryDeclaration<PoTabDropdownComponent, never>;
    static ɵcmp: i0.ɵɵComponentDeclaration<PoTabDropdownComponent, "po-tab-dropdown", never, { "label": "p-label"; "small": "p-small"; "tabs": "p-tabs"; }, { "activated": "p-activated"; "changeState": "p-change-state"; "click": "p-click"; }, never, never, false>;
}
