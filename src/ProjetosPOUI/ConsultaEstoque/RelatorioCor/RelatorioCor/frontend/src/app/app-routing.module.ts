import { NgModule } from '@angular/core';
import { RouterModule, Routes } from '@angular/router';
import { RelatorioCorComponent } from './pages/relatorio-cor/relatorio-cor.component';

const routes: Routes = [
  { path: '', redirectTo: '/relatorio-cor', pathMatch: 'full' },
  { path: 'relatorio-cor', component: RelatorioCorComponent },
  { path: '**', redirectTo: '/relatorio-cor' }
];

@NgModule({
  imports: [RouterModule.forRoot(routes)],
  exports: [RouterModule]
})
export class AppRoutingModule { }
