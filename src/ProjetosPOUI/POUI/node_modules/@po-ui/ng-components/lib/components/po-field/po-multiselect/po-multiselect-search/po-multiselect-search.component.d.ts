import { ChangeDetectorRef, ElementRef, EventEmitter } from '@angular/core';
import { PoMultiselectLiterals } from '../../index';
import * as i0 from "@angular/core";
/**
 * @docsPrivate
 *
 * @description
 *
 * Componente de pesquisa que será criado dentro do dropdown do `po-multiselect`.
 */
export declare class PoMultiselectSearchComponent {
    private cd;
    inputElement: ElementRef;
    /** Propriedade que recebe as literais definidas no `po-multiselect`. */
    literals?: PoMultiselectLiterals;
    fieldValue: string;
    /** Evento que será disparado a cada tecla digitada no campo de busca. */
    change: EventEmitter<any>;
    private _placeholder?;
    constructor(cd: ChangeDetectorRef);
    /**
     * @optional
     *
     * @description
     *
     * Placeholder do campo de pesquisa.
     *
     * > Caso o mesmo não seja informado, o valor padrão será traduzido com base no idioma do navegador (pt, es e en).
     *
     * @default `Buscar`
     */
    set placeholder(placeholder: string);
    get placeholder(): string;
    get inputValue(): any;
    onChange(event: any): void;
    setFocus(): void;
    clean(): void;
    static ɵfac: i0.ɵɵFactoryDeclaration<PoMultiselectSearchComponent, never>;
    static ɵcmp: i0.ɵɵComponentDeclaration<PoMultiselectSearchComponent, "po-multiselect-search", never, { "literals": "p-literals"; "fieldValue": "p-field-value"; "placeholder": "p-placeholder"; }, { "change": "p-change"; }, never, never, false>;
}
