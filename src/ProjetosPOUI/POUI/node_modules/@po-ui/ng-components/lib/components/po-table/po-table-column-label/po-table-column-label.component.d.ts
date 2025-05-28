import { PoColorPaletteService } from './../../../services/po-color-palette/po-color-palette.service';
import { PoTableColumnLabel } from './po-table-column-label.interface';
import * as i0 from "@angular/core";
/**
 * @docsPrivate
 *
 * @description
 *
 * Componente para a criação da representação da legenda, em formato de texto .
 */
export declare class PoTableColumnLabelComponent {
    private poColorPaletteService;
    private _value;
    /** Objeto com os dados do label */
    set value(value: PoTableColumnLabel);
    get value(): PoTableColumnLabel;
    constructor(poColorPaletteService: PoColorPaletteService);
    static ɵfac: i0.ɵɵFactoryDeclaration<PoTableColumnLabelComponent, never>;
    static ɵcmp: i0.ɵɵComponentDeclaration<PoTableColumnLabelComponent, "po-table-column-label", never, { "value": "p-value"; }, {}, never, never, false>;
}
