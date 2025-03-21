import { ElementRef, EventEmitter, OnChanges, OnDestroy, SimpleChanges, Renderer2 } from '@angular/core';
import { PoCheckboxGroupOption } from '../../po-field/po-checkbox-group/interfaces/po-checkbox-group-option.interface';
import { PoPopoverComponent } from '../../po-popover/po-popover.component';
import { PoLanguageService } from '../../../services/po-language/po-language.service';
import { PoTableColumn } from '../interfaces/po-table-column.interface';
import * as i0 from "@angular/core";
export declare const poTableColumnManagerLiteralsDefault: {
    en: {
        columnsManager: string;
        restoreDefault: string;
    };
    es: {
        columnsManager: string;
        restoreDefault: string;
    };
    pt: {
        columnsManager: string;
        restoreDefault: string;
    };
    ru: {
        columnsManager: string;
        restoreDefault: string;
    };
};
export declare class PoTableColumnManagerComponent implements OnChanges, OnDestroy {
    private renderer;
    popover: PoPopoverComponent;
    columns: Array<PoTableColumn>;
    target: ElementRef;
    colunsDefault: Array<PoTableColumn>;
    lastVisibleColumnsSelected: Array<PoTableColumn>;
    visibleColumnsChange: EventEmitter<PoTableColumn[]>;
    changeVisibleColumns: EventEmitter<string[]>;
    initialColumns: EventEmitter<String[]>;
    literals: any;
    columnsOptions: Array<PoCheckboxGroupOption>;
    visibleColumns: Array<string>;
    columnUpdate: any;
    private _maxColumns;
    private defaultColumns;
    private resizeListener;
    private restoreDefaultEvent;
    private lastEmittedValue;
    private minColumns;
    set maxColumns(value: number);
    get maxColumns(): number;
    constructor(renderer: Renderer2, languageService: PoLanguageService);
    ngOnChanges(changes: SimpleChanges): void;
    ngOnDestroy(): void;
    checkChanges(event?: Array<string>, emit?: boolean): void;
    restore(): void;
    changePosition({ option, direction }: {
        option: any;
        direction: any;
    }): void;
    private changePositionColumn;
    private verifyToEmitChange;
    private emitChangesToSelectedColumns;
    private allowsChangeVisibleColumns;
    private verifyToEmitVisibleColumns;
    private verifyRestoreValues;
    private allowsChangeSelectedColumns;
    private verifyOnClose;
    private emitVisibleColumns;
    private allowsEmission;
    private isFirstTime;
    private isUpdate;
    private isEqualArrays;
    private disableColumnsOptions;
    private getColumnTitleLabel;
    /** Retorna um Array de column.property das colunas que são visiveis. */
    private getVisibleColumns;
    private isVisibleColumn;
    /** Retorna um Array PoTableColumn a partir das colunas visiveis no gerenciador de colunas. */
    private getVisibleTableColumns;
    private initializeListeners;
    private isDisableColumn;
    private mapTableColumnsToCheckboxOptions;
    private disabledLastColumn;
    private onChangeColumns;
    private updateValues;
    private removeListeners;
    private stringify;
    static ɵfac: i0.ɵɵFactoryDeclaration<PoTableColumnManagerComponent, never>;
    static ɵcmp: i0.ɵɵComponentDeclaration<PoTableColumnManagerComponent, "po-table-column-manager", never, { "columns": "p-columns"; "target": "p-target"; "colunsDefault": "p-columns-default"; "lastVisibleColumnsSelected": "p-last-visible-columns-selected"; "maxColumns": "p-max-columns"; }, { "visibleColumnsChange": "p-visible-columns-change"; "changeVisibleColumns": "p-change-visible-columns"; "initialColumns": "p-initial-columns"; }, never, never, false>;
}
