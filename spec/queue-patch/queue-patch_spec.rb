# encoding: UTF-8

require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe QueuePatch do
  it "matches http urls" do
    url='http://tickets.opscode.com/browse/CHEF-1940'
    md = QueuePatch::URL_MATCH.match(url)
    md[0].should == url
  end

  it "matches chef and ohai ticket numbers" do
    "CHEF-1234".match(QueuePatch::TICKET_MATCH)[0].should == "CHEF-1234"
    "chef-1234".match(QueuePatch::TICKET_MATCH)[0].should == "chef-1234"
    "OHAI-123".match(QueuePatch::TICKET_MATCH)[0].should == "OHAI-123"
  end

  it "matches github usernames and fork/branches" do
    pull_req_subject = "brucek wants someone to pull from brucek:CHEF-1940"
    pull_req_subject.match(QueuePatch::PULL_REQ)[0].should == pull_req_subject
  end

end

describe QueuePatch::PatchData do
  before do
    @pull_req = IO.read(fixture("pull-request.txt"))
    @patch_data = QueuePatch::PatchData.new(@pull_req)
  end

  it "extracts the urls" do
    @patch_data.urls.should == ['http://tickets.opscode.com/browse/CHEF-1940', 'https://github.com/opscode/chef/pull/41']
  end

  it "extracts the ticket numbers" do
    @patch_data.tickets.should == ['CHEF-1940']
  end

  it "extracts github usernames" do
    @patch_data.github_user.should == "brucek"
  end

  it "extracts github branches" do
    @patch_data.github_branch.should == "CHEF-1940"
  end

end

__END__

> queue-patch add
CHEF-1234
http://tickets.opscode.com/browse/CHEF-1940
https://github.com/opscode/chef/pull/41
# read from STDIN and regex out the ticket number, etc.
> queue-patch paste
# use `pbpaste` to parse a copied email (i.e., a pull req)
> queue-patch paste -t cla,ticket
# use `pbpaste` to parse a copied email (i.e., a pull req) and add tags
> queue-patch list
# list the tickets in markdown
> queue-patch list -b
# display the tickets in the browser