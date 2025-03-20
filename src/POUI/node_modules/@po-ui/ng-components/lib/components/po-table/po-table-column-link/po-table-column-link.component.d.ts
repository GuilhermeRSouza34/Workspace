import * as i0 from "@angular/core";
/**
 * @docsPrivate
 *
 * @description
 *
 * Componente responsável por exibir link nas colunas.
 */
export declare class PoTableColumnLinkComponent {
    action: Function;
    disabled: boolean;
    link: string;
    row: any;
    value: string;
    get type(): "disabled" | "action" | "externalLink" | "internalLink";
    static ɵfac: i0.ɵɵFactoryDeclaration<PoTableColumnLinkComponent, never>;
    static ɵcmp: i0.ɵɵComponentDeclaration<PoTableColumnLinkComponent, "po-table-column-link", never, { "action": "p-action"; "disabled": "p-disabled"; "link": "p-link"; "row": "p-row"; "value": "p-value"; }, {}, never, never, false>;
}
