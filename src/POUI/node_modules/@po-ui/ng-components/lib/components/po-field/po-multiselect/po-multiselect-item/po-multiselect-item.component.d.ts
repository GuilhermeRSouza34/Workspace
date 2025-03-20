import { EventEmitter } from '@angular/core';
import * as i0 from "@angular/core";
/**
 * @docsPrivate
 *
 * @description
 *
 * Componente que constrói cada item no dropdown, contendo o checkbox e o label.
 */
export declare class PoMultiselectItemComponent {
    /** Rótulo do item. */
    label: string;
    /** Esta propriedade indica se o campo está selecionado, indenterminate ou não. */
    selected?: boolean;
    /** Evento que será disparado toda vez que o usuário marcar ou desmarcar um item. */
    change: EventEmitter<any>;
    itemClicked(): void;
    static ɵfac: i0.ɵɵFactoryDeclaration<PoMultiselectItemComponent, never>;
    static ɵcmp: i0.ɵɵComponentDeclaration<PoMultiselectItemComponent, "po-multiselect-item", never, { "label": "p-label"; "selected": "p-selected"; }, { "change": "p-change"; }, never, never, false>;
}
