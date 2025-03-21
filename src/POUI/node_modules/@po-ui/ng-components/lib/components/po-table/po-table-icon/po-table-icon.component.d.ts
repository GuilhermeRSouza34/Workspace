import { EventEmitter, TemplateRef } from '@angular/core';
import * as i0 from "@angular/core";
/**
 * @docsPrivate
 *
 * @description
 *
 * Componente responsável por exibir um ícone na tabela.
 */
export declare class PoTableIconComponent {
    /** Define se o ícone é clicável. */
    clickable: boolean;
    /** Cor do ícone. */
    color: string;
    /** Desabilitado. */
    disabled: boolean;
    /** Classe css do ícone. */
    icon: string | TemplateRef<void>;
    /** Texto do tooltip. */
    iconTooltip: string;
    /** Output click. */
    click: EventEmitter<any>;
    tooltip: string;
    private get allowTooltip();
    onClick(event: any): void;
    tooltipMouseEnter(): void;
    tooltipMouseLeave(): void;
    static ɵfac: i0.ɵɵFactoryDeclaration<PoTableIconComponent, never>;
    static ɵcmp: i0.ɵɵComponentDeclaration<PoTableIconComponent, "po-table-icon", never, { "clickable": "p-clickable"; "color": "p-color"; "disabled": "p-disabled"; "icon": "p-icon"; "iconTooltip": "p-icon-tooltip"; }, { "click": "p-click"; }, never, never, false>;
}
