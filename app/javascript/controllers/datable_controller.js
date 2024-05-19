import { Controller } from "@hotwired/stimulus"

import DataTable from "datatables.net-bs5"

// Connects to data-controller="datable"
export default class extends Controller {
  constructor(...args) {
      super(...args);
      this.dataTable = null;
    
  }

  connect() {
    this.intTable()
  }

  intTable(){
     this.dataTable =  new DataTable(document.getElementById("article_table"),{
        searching: false, // 禁用搜索框
        searchable: false,
        serverSide: true,
        retrieve: true,
        ajax: {
          "url": "/articles.json",
          "type": "GET",
          "data": function(d) {
              d.per = d.length || 10; // 设置默认的每页显示条数
              d.page = d.start / d.length + 1; // 计算当前页码
              
              // 获取表单元素
              const formElement = document.getElementById("search-form");

              // 创建 FormData 对象并传入表单元素
              const formData = new FormData(formElement);

              const formDataObject = {};
              for (const [key, value] of formData.entries()) {
                formDataObject[key] = value;
              }
              // 将 formDataObject 添加到 ajax 请求中
              let sortColumnIndex = d.order[0].column
              // 添加排序
              formDataObject["s"] = d.columns[sortColumnIndex].data + " " + d.order[0].dir            
              // 添加 Ransack 查询参数到请求中
              d.q = formDataObject;

            }
        },
        columns: [
          {
               data: null,
               orderable: false,
               render: function (data, type, row, meta) {
                   return meta.row + 1
               }
           },
           { data: 'title',orderable: true },
           { data: 'kind',orderable: false },
           { 
              data: 'published',
              orderable: false,
              render: function(data, type, row, meta){
                return row.published ? "已发布" : "未发布"
              } 
            },
           { data: 'content',orderable: false },
           {
              data: null,
              orderable: false,
              render: function (data, type, row, meta) {
                return row.actions_html
              }
            },

         ]
      })

     this.dataTable.on('draw.dt', () => {
      // 重新渲染表格时 给tr添加id
        var rows = this.dataTable.rows().nodes();
        for (var i = 0; i < rows.length; i++) {
          rows[i].setAttribute('id', `article_${this.dataTable.row(i).data().id}`);
        }
    });
  }

  handleClick(event){
    event.preventDefault();
    this.dataTable.ajax.reload();
  }
}
