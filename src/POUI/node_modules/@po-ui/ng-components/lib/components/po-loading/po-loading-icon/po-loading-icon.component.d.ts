import * as i0 from "@angular/core";
/**
 * @docsPrivate
 *
 * @description
 *
 * Componente que exibe um ícone de carregamento de conteúdo. A cor padrão para ele é a primária conforme o tema utilizado.
 * É possível alterá-la para um tom cinza conforme a necessidade.
 */
export declare class PoLoadingIconComponent {
    private _neutralColor;
    /**
     * @optional
     *
     * @description
     *
     * Definição para cor neutra (cinza) para o ícone de carregamento.
     *
     * @default `false`
     */
    set neutralColor(value: boolean);
    get neutralColor(): boolean;
    static ɵfac: i0.ɵɵFactoryDeclaration<PoLoadingIconComponent, never>;
    static ɵcmp: i0.ɵɵComponentDeclaration<PoLoadingIconComponent, "po-loading-icon", never, { "neutralColor": "p-neutral-color"; }, {}, never, never, false>;
}
