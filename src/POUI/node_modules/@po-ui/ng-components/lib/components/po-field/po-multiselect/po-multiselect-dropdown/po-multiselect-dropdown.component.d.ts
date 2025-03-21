import { ChangeDetectorRef, ElementRef, EventEmitter } from '@angular/core';
import { PoMultiselectLiterals } from '../../index';
import { PoMultiselectOption } from '../po-multiselect-option.interface';
import { PoMultiselectSearchComponent } from './../po-multiselect-search/po-multiselect-search.component';
import * as i0 from "@angular/core";
/**
 * @docsPrivate
 *
 * @description
 *
 * Componente que construíra o dropdown, contendo o campo de pesquisa e os itens para seleção.
 */
export declare class PoMultiselectDropdownComponent {
    private cd;
    /** Propriedade que indica se deve exibir o loading. */
    isServerSearching?: boolean;
    /** Propriedade que indica se o campo de pesquisa deverá ser escondido. */
    hideSearch?: boolean;
    /** Propriedade que que recebe as literais definidas no componente `po-multiselect`. */
    literals?: PoMultiselectLiterals;
    /** Placeholder do campo de pesquisa. */
    placeholderSearch: string;
    /** Propriedade que recebe a lista de opções selecionadas. */
    selectedOptions: Array<any>;
    /** Propriedade que recebe a lista com todas as opções. */
    options: Array<PoMultiselectOption | any>;
    /** Propriedade que recebe a lista de opções que deverão ser criadas no dropdown. */
    visibleOptions: Array<PoMultiselectOption | any>;
    /** Propriedade que indica se o campo "Selecionar todos" deverá ser escondido. */
    hideSelectAll?: boolean;
    fieldValue: string;
    fieldLabel: string;
    /** Evento disparado a cada tecla digitada na pesquisa. */
    changeSearch: EventEmitter<any>;
    /** Evento disparado a cada alteração na lista das opções selecionadas. */
    change: EventEmitter<any>;
    /**
     * Evento disparado quando for detectada uma ação que necessite fechar o dropdown.
     * Por exemplo, no caso de ser teclado TAB dentro do dropdown, então é disparado este evento
     * para notificar o componente principal que deve fechar o dropdown.
     */
    closeDropdown: EventEmitter<any>;
    container: ElementRef;
    ulElement: ElementRef;
    searchElement: PoMultiselectSearchComponent;
    scrollTop: number;
    show: boolean;
    constructor(cd: ChangeDetectorRef);
    get hasOptions(): boolean;
    onKeydown(event: any): void;
    scrollTo(index: any): void;
    isSelectedItem(option: PoMultiselectOption): boolean;
    clickItem(check: any, option: any): void;
    onClickSelectAll(): void;
    updateSelectedValues(checked: any, option: any): void;
    everyVisibleOptionsSelected(selectedValues: any): boolean;
    someVisibleOptionsSelected(selectedValues: any): boolean;
    getStateSelectAll(): boolean;
    callChangeSearch(event: any): void;
    controlVisibility(toOpen: any): void;
    private uniqueSelectedOptions;
    static ɵfac: i0.ɵɵFactoryDeclaration<PoMultiselectDropdownComponent, never>;
    static ɵcmp: i0.ɵɵComponentDeclaration<PoMultiselectDropdownComponent, "po-multiselect-dropdown", never, { "isServerSearching": "p-searching"; "hideSearch": "p-hide-search"; "literals": "p-literals"; "placeholderSearch": "p-placeholder-search"; "selectedOptions": "p-selected-options"; "options": "p-options"; "visibleOptions": "p-visible-options"; "hideSelectAll": "p-hide-select-all"; "fieldValue": "p-field-value"; "fieldLabel": "p-field-label"; }, { "changeSearch": "p-change-search"; "change": "p-change"; "closeDropdown": "p-close-dropdown"; }, never, never, false>;
}
