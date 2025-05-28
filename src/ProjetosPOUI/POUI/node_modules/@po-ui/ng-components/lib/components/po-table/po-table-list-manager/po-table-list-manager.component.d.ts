import { ChangeDetectorRef } from '@angular/core';
import { PoTableColumn } from '../interfaces/po-table-column.interface';
import { PoLanguageService } from '../../../services/po-language/po-language.service';
import { PoCheckboxGroupComponent } from '../../po-field/po-checkbox-group/po-checkbox-group.component';
import * as i0 from "@angular/core";
export declare const poTableListManagerLiterals: {
    en: {
        up: string;
        down: string;
    };
    es: {
        up: string;
        down: string;
    };
    pt: {
        up: string;
        down: string;
    };
    ru: {
        up: string;
        down: string;
    };
};
declare type Direction = 'up' | 'down';
export declare class PoTableListManagerComponent extends PoCheckboxGroupComponent {
    private changePosition;
    columnsManager: Array<PoTableColumn>;
    literals: any;
    constructor(languageService: PoLanguageService, changeDetector: ChangeDetectorRef);
    emitChangePosition(option: any, direction: Direction): void;
    verifyArrowDisabled(option: any, direction: Direction): boolean;
    static ɵfac: i0.ɵɵFactoryDeclaration<PoTableListManagerComponent, never>;
    static ɵcmp: i0.ɵɵComponentDeclaration<PoTableListManagerComponent, "po-table-list-manager", never, { "columnsManager": "p-columns-manager"; }, { "changePosition": "p-change-position"; }, never, never, false>;
}
export {};
