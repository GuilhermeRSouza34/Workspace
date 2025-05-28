import { EventEmitter, TemplateRef } from '@angular/core';
import * as i0 from "@angular/core";
/**
 * @description
 *
 * O `po-button` permite que o usuário execute ações predefinidas pelo desenvolvedor.
 *
 * Através dos tipos, é possível identificar a importância de cada ação.
 *
 * #### Boas práticas
 *
 * - Evite `labels` extensos que quebram o layout do `po-button`, use `labels` diretos, curtos e intuitivos.
 * - Utilize apenas um `po-button` configurado como `primary` por página.
 * - Para ações irreversíveis use sempre a propriedade `p-danger`.
 *
 * #### Acessibilidade tratada no componente
 *
 * Algumas diretrizes de acessibilidade já são tratadas no componente, internamente, e não podem ser alteradas pelo proprietário do conteúdo. São elas:
 *
 * - Quando em foco, o botão é ativado usando as teclas de Espaço e Enter do teclado. [W3C WAI-ARIA 3.5 Button - Keyboard Interaction](https://www.w3.org/WAI/ARIA/apg/#keyboard-interaction-3)
 * - A área do foco precisar ter uma espessura de pelo menos 2 pixels CSS e o foco não pode ficar escondido por outros elementos da tela. [WCAG 2.4.12: Focus Appearance](https://www.w3.org/WAI/WCAG22/Understanding/focus-appearance-enhanced)
 */
export declare class PoButtonBaseComponent {
    /**
     * @optional
     *
     * @description
     *
     * Label do botão.
     */
    label?: string;
    /**
     * @optional
     *
     * @description
     * Ícone exibido ao lado esquerdo do label do botão.
     *
     * É possível usar qualquer um dos ícones da [Biblioteca de ícones](/guides/icons). conforme exemplo abaixo:
     * ```
     * <po-button p-icon="po-icon-user" p-label="PO button"></po-button>
     * ```
     * Também é possível utilizar outras fontes de ícones, por exemplo a biblioteca *Font Awesome*, da seguinte forma:
     * ```
     * <po-button p-icon="fa fa-podcast" p-label="PO button"></po-button>
     * ```
     * Outra opção seria a customização do ícone através do `TemplateRef`, conforme exemplo abaixo:
     * ```
     * <po-button [p-icon]="template" p-label="button template ionic"></po-button>
     *
     * <ng-template #template>
     *  <ion-icon style="font-size: inherit" name="heart"></ion-icon>
     * </ng-template>
     * ```
     * > Para o ícone enquadrar corretamente, deve-se utilizar `font-size: inherit` caso o ícone utilizado não aplique-o.
     */
    icon?: string | TemplateRef<void>;
    /** Ação que será executada quando o usuário clicar sobre o `po-button`. */
    click: EventEmitter<null>;
    private _danger?;
    private _disabled?;
    private _loading?;
    private _kind?;
    private _size?;
    private _small?;
    protected hasSize?: boolean;
    /**
     * @optional
     *
     * @description
     *
     * Exibe um ícone de carregamento à esquerda do _label_ do botão.
     *
     * > Quando esta propriedade estiver habilitada, desabilitará o botão.
     *
     * @default `false`
     */
    set loading(value: boolean);
    get loading(): boolean;
    /**
     * @deprecated 16.x.x
     *
     * @optional
     *
     * @description
     *
     * **Deprecated 16.x.x**.
     *
     * > Por regras de acessibilidade o botão não terá mais um tamanho menor do que 44px e por isso a propriedade será depreciada.
     * > [Saiba mais](https://animaliads.notion.site/Bot-o-fb3a921e8ba54bd38b39758c24613368)
     *
     * Deixa o botão menor, com 32px de altura.
     *
     * @default `false`
     */
    set small(value: boolean);
    get small(): boolean;
    /**
     * @deprecated 15.x.x
     *
     * @optional
     *
     * @description
     *
     * **Deprecated 15.x.x**. Utilizar `p-kind` no lugar.
     *
     * Define o estilo do `po-button`.
     *
     * Valore válidos:
     *  - `default`: **Deprecated 15.x.x**. Utilizar `p-kind="secondary"`.
     *  - `primary`: deixa o `po-button` com destaque, deve ser usado para ações primárias.
     *  - `danger`: **Deprecated 15.x.x**. Utilizar `p-danger`.
     *  - `link`: **Deprecated 15.x.x**. Utilizar `p-kind="tertiary"`.
     *
     * @default `secondary`
     */
    set type(value: string);
    get type(): string;
    /**
     * @optional
     *
     * @description
     *
     * Deve ser usado em ações irreversíveis que o usuário precisa ter cuidado ao executá-la, como a exclusão de um registro.
     *
     * > A propriedade `p-kind="tertiary"` será inativada ao utilizar esta propriedade.
     */
    set danger(value: boolean);
    get danger(): boolean;
    /**
     * @optional
     *
     * @description
     *
     * Define o tamanho do `po-button`.
     *
     * Valores válidos:
     * - `medium`: o `po-button` fica do tamanho padrão, com 44px de altura.;
     * - `large`: o `po-button` fica maior, com 56px de altura.;
     *
     * @default `medium`
     *
     */
    set size(value: string);
    get size(): string;
    /**
     * @optional
     *
     * @description
     *
     * Define o estilo do `po-button`.
     *
     * Valores válidos:
     *  - `primary`: deixa o `po-button` com destaque, deve ser usado para ações primárias.
     *  - `secondary`: estilo padrão do `po-button`.
     *  - `tertiary`: o `po-button` é exibido sem cor do fundo, recebendo menos destaque entre as ações.
     *
     * @default `secondary`
     */
    set kind(value: string);
    get kind(): string;
    /**
     * @optional
     *
     * @description
     *
     * Desabilita o `po-button` e não permite que o usuário interaja com o mesmo.
     *
     * @default `false`
     */
    set disabled(value: boolean);
    get disabled(): boolean;
    static ɵfac: i0.ɵɵFactoryDeclaration<PoButtonBaseComponent, never>;
    static ɵdir: i0.ɵɵDirectiveDeclaration<PoButtonBaseComponent, never, never, { "label": "p-label"; "icon": "p-icon"; "loading": "p-loading"; "small": "p-small"; "type": "p-type"; "danger": "p-danger"; "size": "p-size"; "kind": "p-kind"; "disabled": "p-disabled"; }, { "click": "p-click"; }, never, never, false>;
}
