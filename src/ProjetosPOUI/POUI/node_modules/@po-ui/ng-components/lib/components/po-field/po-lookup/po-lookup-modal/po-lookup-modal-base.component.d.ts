import { EventEmitter, OnDestroy, OnInit, ChangeDetectorRef } from '@angular/core';
import { PoModalAction } from '../../../../components/po-modal';
import { PoModalComponent } from '../../../../components/po-modal/po-modal.component';
import { PoTableColumnSort } from '../../../po-table/interfaces/po-table-column-sort.interface';
import { PoLanguageService } from '../../../../services/po-language/po-language.service';
import { PoLookupColumn } from '../interfaces/po-lookup-column.interface';
import { PoLookupFilter } from '../interfaces/po-lookup-filter.interface';
import { PoLookupLiterals } from '../interfaces/po-lookup-literals.interface';
import { PoDisclaimer } from './../../../po-disclaimer/po-disclaimer.interface';
import { PoDisclaimerGroup } from './../../../po-disclaimer-group/po-disclaimer-group.interface';
import { PoLookupAdvancedFilter } from '../interfaces/po-lookup-advanced-filter.interface';
import { PoTableComponent } from './../../../po-table/po-table.component';
import * as i0 from "@angular/core";
export declare const poLookupLiteralsDefault: {
    en: PoLookupLiterals;
    es: PoLookupLiterals;
    pt: PoLookupLiterals;
    ru: PoLookupLiterals;
};
/**
 * @docsPrivate
 *
 * Classe base do componente Po Lookup Modal.
 */
export declare abstract class PoLookupModalBaseComponent implements OnDestroy, OnInit {
    protected changeDetector: ChangeDetectorRef;
    poModal: PoModalComponent;
    poTable: PoTableComponent;
    /**
     * Objeto com os campos que serão criados no busca avançada.
     *
     * > Caso não seja passado um objeto ou então ele esteja em branco o link de busca avançada ficará escondido.
     *
     * Exemplo de URL com busca avançada: http://localhost:3000/v1/heroes?filter=&page=1&pageSize=10`&name=Tony%20Stark&nickname=Homem%20de%20Ferro&email=irnman@marvel.com`
     *
     * Caso algum parâmetro seja uma lista, a concatenação é feita utilizando virgula.
     * Exemplo: http://localhost:3000/v1/heroes?filter=&page=1&pageSize=10`&name=Tony%20Stark,Peter%20Parker,Gohan`
     *
     */
    advancedFilters: Array<PoLookupAdvancedFilter>;
    /**
     * Lista das colunas da tabela.
     * Essa propriedade deve receber um array de objetos que implementam a interface PoLookupColumn.
     */
    columns: Array<PoLookupColumn>;
    /** Lista de itens da tabela. */
    items: Array<any>;
    /** Classe de serviço com a implementação do cliente. */
    filterService: PoLookupFilter;
    /** Classe de serviço com a implementação do cliente. */
    filterParams: any;
    /** Se verdadeiro, ativa a funcionalidade de scroll infinito para a tabela exibida no retorno da consulta. */
    infiniteScroll: boolean;
    /** Se verdadeiro, ativa a funcionalidade de multipla seleção. */
    multiple: boolean;
    /** Evento utilizado ao selecionar um registro da tabela. */
    model: EventEmitter<any>;
    /** Classe de serviço com items selecionados */
    selectedItems: any;
    /** Indica a coluna que será utilizada como descrição do campo e como filtro dentro da janela. */
    fieldLabel: string;
    /**
     * @description
     *
     * Indica a coluna que será utilizada como valor do campo.
     *
     * > Atenção: Caso não seja passada ou tenha o conteúdo incorreto, não irá atualizar o model do formulário.
     */
    fieldValue: string;
    /**
     * @optional
     *
     * @description
     * Evento disparado ao fechar o popover do gerenciador de colunas após alterar as colunas visíveis.
     *
     * O componente envia como parâmetro um array de string com as colunas visíveis atualizadas.
     * Por exemplo: ["idCard", "name", "hireStatus", "age"].
     */
    changeVisibleColumns: EventEmitter<string[]>;
    /**
     * @optional
     *
     * @description
     * Evento disparado ao clicar no botão de restaurar padrão no gerenciador de colunas.
     *
     * O componente envia como parâmetro um array de string com as colunas configuradas inicialmente.
     * Por exemplo: ["idCard", "name", "hireStatus", "age"].
     */
    columnRestoreManager: EventEmitter<String[]>;
    hasNext: boolean;
    isLoading: boolean;
    page: number;
    pageSize: number;
    searchValue: string;
    tableLiterals: any;
    advancedFilterModalTitle: string;
    dynamicFormValue: {};
    disclaimer: PoDisclaimer;
    disclaimerGroup: PoDisclaimerGroup;
    isAdvancedFilter: boolean;
    primaryActionAdvancedFilter: PoModalAction;
    secondaryActionAdvancedFilter: PoModalAction;
    selecteds: Array<any>;
    protected sort: PoTableColumnSort;
    private filterSubscription;
    private searchSubscription;
    private showMoreSubscription;
    private _literals;
    private _title;
    private language;
    primaryAction: PoModalAction;
    secondaryAction: PoModalAction;
    /** Objeto com as literais usadas no `po-lookup-modal`. */
    set literals(value: PoLookupLiterals);
    get literals(): PoLookupLiterals;
    /** Título da modal. */
    set title(value: string);
    get title(): string;
    constructor(languageService: PoLanguageService, changeDetector: ChangeDetectorRef);
    ngOnDestroy(): void;
    ngOnInit(): void;
    createDisclaimer(): void;
    addDisclaimer(value: any, property: string): void;
    onChangeDisclaimerGroup(): void;
    search(): void;
    searchFilteredItems(): void;
    showMoreEvent(): void;
    setSelectedItems(): void;
    setDisclaimersItems(): void;
    private setAdvancedFilterModalProperties;
    private getAdvancedFilters;
    private getFilteredItems;
    private getFilteredParams;
    private getOrderParam;
    private initializeData;
    private setLookupResponseProperties;
    private setTableLiterals;
    abstract openModal(): void;
    abstract destroyDynamicForm(): void;
    static ɵfac: i0.ɵɵFactoryDeclaration<PoLookupModalBaseComponent, never>;
    static ɵdir: i0.ɵɵDirectiveDeclaration<PoLookupModalBaseComponent, never, never, { "advancedFilters": "p-advanced-filters"; "columns": "p-columns"; "items": "p-items"; "filterService": "p-filter-service"; "filterParams": "p-filter-params"; "infiniteScroll": "p-infinite-scroll"; "multiple": "p-multiple"; "selectedItems": "p-selected-items"; "fieldLabel": "p-field-label"; "fieldValue": "p-field-value"; "literals": "p-literals"; "title": "p-title"; }, { "model": "p-change-model"; "changeVisibleColumns": "p-change-visible-columns"; "columnRestoreManager": "p-restore-column-manager"; }, never, never, false>;
}
