import { NgModule } from '@angular/core';
import { BrowserModule } from '@angular/platform-browser';
import { BrowserAnimationsModule } from '@angular/platform-browser/animations';
import { HttpClientModule } from '@angular/common/http';
import { FormsModule } from '@angular/forms';
import { RouterModule } from '@angular/router';

// Módulos do PO-UI
import { PoModule } from '@po-ui/ng-components';

// Componentes da aplicação
import { AppComponent } from './app.component';
import { AppRoutingModule } from './app-routing.module';
import { DashboardComponent } from './components/dashboard/dashboard.component';
import { PedidosPendentesComponent } from './components/pedidos-pendentes/pedidos-pendentes.component';
import { OrcamentosComponent } from './components/orcamentos/orcamentos.component';

@NgModule({
  declarations: [
    AppComponent,
    DashboardComponent,
    PedidosPendentesComponent,
    OrcamentosComponent
  ],
  imports: [
    BrowserModule,
    BrowserAnimationsModule,
    HttpClientModule,
    FormsModule,
    AppRoutingModule,
    PoModule
  ],
  providers: [],
  bootstrap: [AppComponent]
})
export class AppModule { }
