import { EventEmitter, OnDestroy, TemplateRef } from '@angular/core';
import { PoAccordionService } from '../services/po-accordion.service';
import * as i0 from "@angular/core";
/**
 * @description
 *
 * Componente utilizado para renderizar os itens do `po-accordion`.
 *
 * O componente `po-accordion` já faz o controle de abertura e fechamento dos itens automaticamente,
 * mas caso houver a necessidade de abrir algum dos `po-accordion-item` via Typescript, pode ser feita da seguinte forma:
 *
 * ```
 * <po-accordion>
 *   <po-accordion-item p-label="PO Accordion 1" #item1>
 *      Accordion 1
 *   </po-accordion-item>
 *
 *   <po-accordion-item p-label="PO Accordion 2">
 *      Accordion 2
 *   </po-accordion-item>
 * </po-accordion>
 * ```
 *
 * e no typescript pode-se utilizar o `@ViewChild`:
 *
 * ```
 *  @ViewChild(PoAccordionItemComponent, { static: true }) item1: PoAccordionItemComponent;
 *
 *  ngAfterContentInit() {
 *    // ou utilizar o método collapse()
 *    this.item1.expand();
 *  }
 * ```
 */
export declare class PoAccordionItemComponent implements OnDestroy {
    private accordionService;
    /** Título do item. */
    label: string;
    /** Evento disparado ao expandir o item, seja manualmente ou programaticamente. */
    expandEvent: EventEmitter<void>;
    /** Evento disparado ao retrair o item, seja manualmente ou programaticamente. */
    collapseEvent: EventEmitter<void>;
    templateRef: TemplateRef<any>;
    expanded: boolean;
    private expandSubscription;
    private collapseSubscription;
    constructor(accordionService: PoAccordionService);
    ngOnDestroy(): void;
    /**
     * Método para colapsar o `po-accordion-item`.
     */
    collapse(): void;
    /**
     * Método para expandir o `po-accordion-item`.
     */
    expand(): void;
    static ɵfac: i0.ɵɵFactoryDeclaration<PoAccordionItemComponent, never>;
    static ɵcmp: i0.ɵɵComponentDeclaration<PoAccordionItemComponent, "po-accordion-item", never, { "label": "p-label"; }, { "expandEvent": "p-expand"; "collapseEvent": "p-collapse"; }, never, ["*"], false>;
}
