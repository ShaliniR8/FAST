if Rails::VERSION::MAJOR == 3 && Rails::VERSION::MINOR == 0 && RUBY_VERSION >= "2.0.0"
  module ActiveRecord
    module Associations
      class AssociationProxy
        def send(method, *args)
          if proxy_respond_to?(method, true)
            super
          else
            load_target
            @target.send(method, *args)
          end
        end
      end
    end
  end
end

class FaaReportsController < ApplicationController

  respond_to :docx

  def index
    @reports = FaaReport.find(:all)
    @headers = FaaReport.get_headers
  end



  def enhance
    @report = FaaReport.find(params[:id])
    @issue = Issue.new
    @fields = Issue.get_meta_fields('form')
    render :partial => "enhance"
  end



  def edit_enhancement
    @report = FaaReport.find(params[:id])
    @issue = Issue.find(params[:enhancement])
    render :partial => "enhance"
  end



  def print
    @report = FaaReport.find(params[:id])
    @identification = BaseConfig.faa_info
    html = render_to_string(:template=>"/faa_reports/print.html.erb")
    pdf = PDFKit.new(html)
    pdf.stylesheets << ("#{Rails.root}/public/css/bootstrap.css")
    send_data pdf.to_pdf, :filename => "FAA_Quarterly_Report_#{@report.year}_Quarter#{@report.quarter}.pdf"
  end


  def current
    current_month=Time.now.month
    case current_month
    when 1..3
      current_year=Time.now.year
      current_quarter=1
    when 4..6
      current_year=Time.now.year
      current_quarter=2

    when 7..9
      current_year=Time.now.year
      current_quarter=3

    when 10..12
      current_year=Time.now.year
      current_quarter=4
    end
    rep=FaaReport.where('year=? and quarter=?',current_year,current_quarter)
    if rep.present?
      redirect_to faa_report_path(rep.first)
    else
      redirect_to new_faa_report_path(:year=>current_year,:quarter=>current_quarter)
    end
  end



  def new
    if params[:year].present? && params[:quarter].present?
      @report = FaaReport.get_new(params[:year],params[:quarter])
      @current = true
    else
      @report = FaaReport.new
      @current = false
    end
  end



  def edit
    @current = true
    @report = FaaReport.find(params[:id])
    render :partial => "edit"
  end



  def update
    @report = FaaReport.find(params[:id])
    if @report.update_attributes(params[:faa_report])
      redirect_to faa_report_path(@report), flash: {success: params[:faa_report][:issues_attributes].present? ? "Safety Enhancement added." : "FAA Report updated."}
    end
  end



  def destroy
    FaaReport.find(params[:id]).destroy
    redirect_to faa_reports_path
  end



  def show
    @report = FaaReport.find(params[:id])
    build_stats
    @identification = BaseConfig.faa_info
  end



  def create
    report = FaaReport.new(params[:faa_report])
    if report.save
      redirect_to faa_report_path(report), flash: {success: "FAA Report created."}
    end
  end



  def build_stats
    asap_reports = Record.where("event_date >= ? and event_date <= ?", @report.get_start_date, @report.get_end_date).select{|x| (x.template.name.include? "ASAP") && (x.template.name.include? "#{@report.employee_group}")}
    asap_events = asap_reports.map{|x| x.report}.uniq.compact
    # Number of ASAP reports submitted present quarter
    @report.asap_submit = asap_reports.length
    # Number of ASAP reports accepted present quarter
    @report.asap_accept = asap_events.select{|x| x.asap}.map{|x| x.records.keep_if{|y| (y.template.name.include? "ASAP") && (y.template.name.include? "#{@report.employee_group}")}}.flatten.length
    # Number of accepted reports present quarter that were sole source to the FAA
    @report.sole = asap_events.select{|x| x.asap && x.sole}.map{|x| x.records.keep_if{|y| (y.template.name.include? "ASAP") && (y.template.name.include? "#{@report.employee_group}")}}.flatten.length
    # Number of accepted reports present quarter closed under ASAP
    @report.asap_close = asap_events.select{|x| x.asap && x.status == "Closed"}.map{|x| x.records.keep_if{|y| (y.template.name.include? "ASAP") && (y.template.name.include? "#{@report.employee_group}")}}.flatten.length


    # Number of accepted reports present quarter (both sole source & non-sole source) closed with corrective action under ASAP for the employee
    @report.asap_emp = asap_reports.select{|x| (x.report.present? && x.report.asap && x.report.has_emp) || (x.has_emp)}.keep_if{|y| (y.template.name.include? "ASAP") && (y.template.name.include? "#{@report.employee_group}")}.flatten.length


    # Number of reports present quarter, which resulted in recommendations to the company for corrective action
    @report.asap_com = asap_reports.select{|x| (x.report.present? && x.report.asap && x.report.has_com) || (x.has_com)}.keep_if{|y| (y.template.name.include? "ASAP") && (y.template.name.include? "#{@report.employee_group}")}.flatten.length


    @report.save
  end



  def reports_table
    @headers = Record.get_headers
    @report = FaaReport.find(params[:id])

    asap_reports = Record.where("event_date >= ? and event_date <= ?", @report.get_start_date, @report.get_end_date).select{|x| (x.template.name.include? "ASAP") && (x.template.name.include? "#{@report.employee_group}")}
    asap_events = asap_reports.map{|x| x.report}.uniq.compact

    case params[:mode].to_i
    when 1
      @result = asap_reports
      @title = "ASAP Reports Submitted"
    when 2
      @result = asap_events.select{|x| x.asap}.map{|x| x.records.keep_if{|y| (y.template.name.include? "ASAP") && (y.template.name.include? "#{@report.employee_group}")}}.flatten
      @title = "ASAP Reports Accepted"
    when 3
      @result = asap_events.select{|x| x.asap && x.sole}.map{|x| x.records.keep_if{|y| (y.template.name.include? "ASAP") && (y.template.name.include? "#{@report.employee_group}")}}.flatten
      @title = "Accepted Reports Sole Source to the FAA:"
    when 4
      @result = asap_reports.select{|x| (x.report.present? && x.report.asap && x.report.has_emp) || (x.has_emp)}.keep_if{|y| (y.template.name.include? "ASAP") && (y.template.name.include? "#{@report.employee_group}")}.flatten
      @title = "Accepted Reports present (both sole source & non-sole source) with Corrective Action under ASAP for the Employee"
    when 5
      @result = asap_events.select{|x| x.asap && x.status == "Closed"}.map{|x| x.records.keep_if{|y| (y.template.name.include? "ASAP") && (y.template.name.include? "#{@report.employee_group}")}}.flatten
      @title = "Accepted Reports Closed under ASAP"
    when 6
      @title = "Reports present with Recommendations to the Company for Corrective Action"
      @result = asap_reports.select{|x| (x.report.present? && x.report.asap && x.report.has_com) || (x.has_com)}.keep_if{|y| (y.template.name.include? "ASAP") && (y.template.name.include? "#{@report.employee_group}")}.flatten
    end
    render :partial => "table"
  end



  def export_word
    require "docx"
    @report = FaaReport.find(params[:id])
    doc = Docx::Document.open("#{Rails.root}/public/test.docx")
    doc.paragraphs.each do |p|

      # Identification
      p.text = p.to_s.sub("$chdo$", BaseConfig.faa_info["CHDO"])
      p.text = p.to_s.sub("$region$", BaseConfig.faa_info["Region"])
      p.text = p.to_s.sub("$fiscal_year$", @report.year.to_s)
      p.text = p.to_s.sub("$fiscal_quarter$", @report.get_fiscal_quarter )
      p.text = p.to_s.sub("$holder_name$", BaseConfig.faa_info["ASAP MOU Holder Name"])
      p.text = p.to_s.sub("$faa_designator$", BaseConfig.faa_info["ASAP MOU Holder FAA Designator"])
      p.text = p.to_s.sub("$employee_group$", @report.employee_group)

      # ASAP ERC Contact Information & Present Quarter Statistics
      p.text = p.to_s.sub("$faa_member$", @report.faa)
      p.text = p.to_s.sub("$company_member$", @report.company)
      p.text = p.to_s.sub("$labor_member$", @report.labor)
      p.text = p.to_s.sub("$asap_manager$", @report.asap)

      # Statistics
      p.text = p.to_s.sub("$asap_submit$", @report.asap_submit.to_s)
      p.text = p.to_s.sub("$asap_accept$", @report.asap_accept.to_s)
      p.text = p.to_s.sub("$sole$", @report.sole.to_s)
      p.text = p.to_s.sub("$asap_emp$", @report.asap_emp.to_s)
      p.text = p.to_s.sub("$asap_com$", @report.asap_com.to_s)

      # Safety Enhancement
      p.text = p.to_s.sub("$safety_enhancements$", @report.safety_enhencement)

    end
    doc.save("#{Rails.root}/public/test-edited.docx")
    output_file = "#{Rails.root}/public/test-edited.docx"

    respond_to do |format|
      format.docx do
        send_file(output_file, filename: "faa_report.docx")
      end
    end


  end




end
