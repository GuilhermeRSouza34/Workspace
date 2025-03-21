import { EventEmitter } from '@angular/core';
import * as i0 from "@angular/core";
/**
 * @docsPrivate
 *
 * @description
 *
 * Componente para o conjunto de círculos que faz a passagem de itens do `po-slide`.
 */
export declare class PoSlideCirclesComponent {
    /** Index do slide atual. */
    currentSlideIndex: number;
    /** Itens do slide. */
    items: Array<any>;
    /** Evento emitido ao clicar em um controle. */
    click: EventEmitter<any>;
    static ɵfac: i0.ɵɵFactoryDeclaration<PoSlideCirclesComponent, never>;
    static ɵcmp: i0.ɵɵComponentDeclaration<PoSlideCirclesComponent, "po-slide-circles", never, { "currentSlideIndex": "p-current-slide-index"; "items": "p-items"; }, { "click": "p-click"; }, never, never, false>;
}
