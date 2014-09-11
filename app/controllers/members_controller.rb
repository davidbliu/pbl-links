class MembersController < ApplicationController
	def test
		# 
		# test all member functions
		# 
		me = Member.where(name: "David Liu").first
		# p me.committees
		# p me.primary_committee
		# p me.current_committee
		# p Member.current_members
		# p me.position
		# p me.tier
	end

	#
	# placeholder as i develop index
	#
	def all
		@semester = Semester.current_semester
		join = CommitteeMember.where(semester: @semester).joins(:member, :committee, :committee_member_type)
  		@current = join.map{|j| {'name'=>j.member.name,'email'=>j.member.email,'phone'=>j.member.phone,'position'=>j.committee_member_type.name, 'committee'=>j.committee.name, 'semester'=>@semester.name}}
		@alumni = Member.alumni.map{|a| {'name'=> a.name, 'email'=>a.email,'phone'=>a.phone,'committee'=>'alumni','position'=>'.','semester'=>'.' }}
	end

	#
	# show unconfirmed members. let secretary confirm them
	#
	def confirm_new
		@committees = Committee.all
		@positions = CommitteeMemberType.all
		@unconfirmed = Member.where(confirmation_status: 1)
		@confirmed_this_semester = Member.where(confirmation_status: 2)

	end

	def process_new
		member_data = params[:member_data]
		p 'this is member_data'
		p member_data
		member_data.each do |key, md|
			# member = Member.find(md['id'].to_i)
			# p member
			member = Member.find(md['id'].to_i)
			committee = Committee.find(md['committee_id'].to_i)
			position_id = md['position_id'].to_i
			position_name = md['position_name']
			# p member.name
			# p 'thats all folks'
			member.update_from_secretary(committee, position_id, position_name)
			member.confirmation_status = 2
			member.save

		end
		render :nothing => true, :status => 200, :content_type => 'text/html'
	end

	#
	# shows only members from current semester
	#
	def index
		@semester = Semester.current_semester
		join = CommitteeMember.where(semester: @semester).joins(:member, :committee, :committee_member_type)
  		@data = join.map{|j| {'name'=>j.member.name,'email'=>j.member.email,'phone'=>j.member.phone,'position'=>j.committee_member_type.name, 'committee'=>j.committee.name, 'semester'=>@semester.name}}
		#
		# better but bad
		#
		# current_members = Member.preload(:committee_members)
		# @committees = Committee.all
		# @curr_semester_id = Semester.current_semester.id
		# @data = Array.new
		# @semesters = Semester.all
		# current_members.each do |m|
		# 	begin
		# 		data = Hash.new
		# 		mems = m.committee_members.joins(:committee_member_type)
		# 		committee_member = mems.where(semester_id: @curr_semester_id).first
		# 		data['name'] = m.name
		# 		data['email'] = m.email
		# 		data['phone'] = m.phone
		# 		data['committee'] = @committees.find(committee_member.committee_id).name
		# 		data['position'] = committee_member.committee_member_type.name
		# 		data['semester'] = @semesters.where('id IN (?)' , mems.pluck(:semester_id)).pluck(:name)
		# 		@data << data
		# 	rescue
		# 		p 'failed'
		# 	end
		# end
		#
		# naive method?
		#
		# current_members = Member.all
		# @data = current_members.map{|m| {'name'=>m.name, 'committee'=>m.current_committee, 'position'=>m.position, 'semester'=>'.'}}
		# @current_members = Member.all
	end

end