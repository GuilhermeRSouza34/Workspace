import { NgModule } from '@angular/core';
import { BrowserModule } from '@angular/platform-browser';
import { BrowserAnimationsModule } from '@angular/platform-browser/animations';
import { HttpClientModule } from '@angular/common/http';
import { FormsModule, ReactiveFormsModule } from '@angular/forms';

// Módulos do PO-UI
import { PoModule } from '@po-ui/ng-components';
import { PoTemplatesModule } from '@po-ui/ng-templates';

// Módulos de gráficos
import { NgChartsModule } from 'ng2-charts';

// Componentes da aplicação
import { AppComponent } from './app.component';
import { AppRoutingModule } from './app-routing.module';
import { DashboardComponent } from './components/dashboard/dashboard.component';
import { PedidosPendentesComponent } from './components/pedidos-pendentes/pedidos-pendentes.component';
import { RankingClientesComponent } from './components/ranking-clientes/ranking-clientes.component';
import { RelatoriosComponent } from './components/relatorios/relatorios.component';

// Serviços
import { FaturamentoService } from './services/faturamento.service';
import { NotificationService } from './services/notification.service';

@NgModule({
  declarations: [
    AppComponent,
    DashboardComponent,
    PedidosPendentesComponent,
    RankingClientesComponent,
    RelatoriosComponent
  ],
  imports: [
    BrowserModule,
    BrowserAnimationsModule,
    HttpClientModule,
    FormsModule,
    ReactiveFormsModule,
    AppRoutingModule,
    
    // PO-UI Modules
    PoModule,
    PoTemplatesModule,
    
    // Charts Module
    NgChartsModule
  ],
  providers: [
    FaturamentoService,
    NotificationService
  ],
  bootstrap: [AppComponent]
})
export class AppModule { }
