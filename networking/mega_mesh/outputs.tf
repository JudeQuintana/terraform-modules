# output routes?
output "peering" {
  value = {
    one = {
      two = {
        attachment_id = aws_ec2_transit_gateway_peering_attachment_accepter.this_one_to_this_two.id
        from          = local.one_tgw.full_name
        to            = local.two_tgw.full_name
      }
    }
    two = {
      three = {
        attachment_id = aws_ec2_transit_gateway_peering_attachment_accepter.this_two_to_this_three.id
        from          = local.two_tgw.full_name
        to            = local.three_tgw.full_name
      }
    }
    three = {
      one = {
        attachment_id = aws_ec2_transit_gateway_peering_attachment_accepter.this_three_to_this_one.id
        from          = local.three_tgw.full_name
        to            = local.one_tgw.full_name
      }
    }
    four = {
      one = {
        attachment_id = aws_ec2_transit_gateway_peering_attachment_accepter.this_four_to_this_one.id
        from          = local.four_tgw.full_name
        to            = local.one_tgw.full_name
      }
      two = {
        attachment_id = aws_ec2_transit_gateway_peering_attachment_accepter.this_four_to_this_two.id
        from          = local.four_tgw.full_name
        to            = local.two_tgw.full_name
      }
      three = {
        attachment_id = aws_ec2_transit_gateway_peering_attachment_accepter.this_four_to_this_three.id
        from          = local.four_tgw.full_name
        to            = local.three_tgw.full_name
      }
    }
    five = {
      one = {
        attachment_id = aws_ec2_transit_gateway_peering_attachment_accepter.this_five_to_this_one.id
        from          = local.five_tgw.full_name
        to            = local.one_tgw.full_name
      }
      two = {
        attachment_id = aws_ec2_transit_gateway_peering_attachment_accepter.this_five_to_this_two.id
        from          = local.five_tgw.full_name
        to            = local.two_tgw.full_name
      }
      three = {
        attachment_id = aws_ec2_transit_gateway_peering_attachment_accepter.this_five_to_this_three.id
        from          = local.five_tgw.full_name
        to            = local.three_tgw.full_name
      }
      four = {
        attachment_id = aws_ec2_transit_gateway_peering_attachment_accepter.this_five_to_this_four.id
        from          = local.five_tgw.full_name
        to            = local.four_tgw.full_name
      }
    }
    six = {
      one = {
        attachment_id = aws_ec2_transit_gateway_peering_attachment_accepter.this_six_to_this_one.id
        from          = local.six_tgw.full_name
        to            = local.one_tgw.full_name
      }
      two = {
        attachment_id = aws_ec2_transit_gateway_peering_attachment_accepter.this_six_to_this_two.id
        from          = local.six_tgw.full_name
        to            = local.two_tgw.full_name
      }
      three = {
        attachment_id = aws_ec2_transit_gateway_peering_attachment_accepter.this_six_to_this_three.id
        from          = local.six_tgw.full_name
        to            = local.three_tgw.full_name
      }
      four = {
        attachment_id = aws_ec2_transit_gateway_peering_attachment_accepter.this_six_to_this_four.id
        from          = local.six_tgw.full_name
        to            = local.four_tgw.full_name
      }
      five = {
        attachment_id = aws_ec2_transit_gateway_peering_attachment_accepter.this_six_to_this_five.id
        from          = local.six_tgw.full_name
        to            = local.five_tgw.full_name
      }
    }
    seven = {
      one = {
        attachment_id = aws_ec2_transit_gateway_peering_attachment_accepter.this_seven_to_this_one.id
        from          = local.seven_tgw.full_name
        to            = local.one_tgw.full_name
      }
      two = {
        attachment_id = aws_ec2_transit_gateway_peering_attachment_accepter.this_seven_to_this_two.id
        from          = local.seven_tgw.full_name
        to            = local.two_tgw.full_name
      }
      three = {
        attachment_id = aws_ec2_transit_gateway_peering_attachment_accepter.this_seven_to_this_three.id
        from          = local.seven_tgw.full_name
        to            = local.three_tgw.full_name
      }
      four = {
        attachment_id = aws_ec2_transit_gateway_peering_attachment_accepter.this_seven_to_this_four.id
        from          = local.seven_tgw.full_name
        to            = local.four_tgw.full_name
      }
      five = {
        attachment_id = aws_ec2_transit_gateway_peering_attachment_accepter.this_seven_to_this_five.id
        from          = local.seven_tgw.full_name
        to            = local.five_tgw.full_name
      }
      six = {
        attachment_id = aws_ec2_transit_gateway_peering_attachment_accepter.this_seven_to_this_six.id
        from          = local.seven_tgw.full_name
        to            = local.six_tgw.full_name
      }
    }
    eight = {
      one = {
        attachment_id = aws_ec2_transit_gateway_peering_attachment_accepter.this_eight_to_this_one.id
        from          = local.eight_tgw.full_name
        to            = local.one_tgw.full_name
      }
      two = {
        attachment_id = aws_ec2_transit_gateway_peering_attachment_accepter.this_eight_to_this_two.id
        from          = local.eight_tgw.full_name
        to            = local.two_tgw.full_name
      }
      three = {
        attachment_id = aws_ec2_transit_gateway_peering_attachment_accepter.this_eight_to_this_three.id
        from          = local.eight_tgw.full_name
        to            = local.three_tgw.full_name
      }
      four = {
        attachment_id = aws_ec2_transit_gateway_peering_attachment_accepter.this_eight_to_this_four.id
        from          = local.eight_tgw.full_name
        to            = local.four_tgw.full_name
      }
      five = {
        attachment_id = aws_ec2_transit_gateway_peering_attachment_accepter.this_eight_to_this_five.id
        from          = local.eight_tgw.full_name
        to            = local.five_tgw.full_name
      }
      six = {
        attachment_id = aws_ec2_transit_gateway_peering_attachment_accepter.this_eight_to_this_six.id
        from          = local.eight_tgw.full_name
        to            = local.six_tgw.full_name
      }
      seven = {
        attachment_id = aws_ec2_transit_gateway_peering_attachment_accepter.this_eight_to_this_seven.id
        from          = local.eight_tgw.full_name
        to            = local.seven_tgw.full_name
      }
    }
    nine = {
      one = {
        attachment_id = aws_ec2_transit_gateway_peering_attachment_accepter.this_nine_to_this_one.id
        from          = local.nine_tgw.full_name
        to            = local.one_tgw.full_name
      }
      two = {
        attachment_id = aws_ec2_transit_gateway_peering_attachment_accepter.this_nine_to_this_two.id
        from          = local.nine_tgw.full_name
        to            = local.two_tgw.full_name
      }
      three = {
        attachment_id = aws_ec2_transit_gateway_peering_attachment_accepter.this_nine_to_this_three.id
        from          = local.nine_tgw.full_name
        to            = local.three_tgw.full_name
      }
      four = {
        attachment_id = aws_ec2_transit_gateway_peering_attachment_accepter.this_nine_to_this_four.id
        from          = local.nine_tgw.full_name
        to            = local.four_tgw.full_name
      }
      five = {
        attachment_id = aws_ec2_transit_gateway_peering_attachment_accepter.this_nine_to_this_five.id
        from          = local.nine_tgw.full_name
        to            = local.five_tgw.full_name
      }
      six = {
        attachment_id = aws_ec2_transit_gateway_peering_attachment_accepter.this_nine_to_this_six.id
        from          = local.nine_tgw.full_name
        to            = local.six_tgw.full_name
      }
      seven = {
        attachment_id = aws_ec2_transit_gateway_peering_attachment_accepter.this_nine_to_this_seven.id
        from          = local.nine_tgw.full_name
        to            = local.seven_tgw.full_name
      }
      eight = {
        attachment_id = aws_ec2_transit_gateway_peering_attachment_accepter.this_nine_to_this_eight.id
        from          = local.nine_tgw.full_name
        to            = local.eight_tgw.full_name
      }
    }
    ten = {
      one = {
        attachment_id = aws_ec2_transit_gateway_peering_attachment_accepter.this_ten_to_this_one.id
        from          = local.ten_tgw.full_name
        to            = local.one_tgw.full_name
      }
      two = {
        attachment_id = aws_ec2_transit_gateway_peering_attachment_accepter.this_ten_to_this_two.id
        from          = local.ten_tgw.full_name
        to            = local.two_tgw.full_name
      }
      three = {
        attachment_id = aws_ec2_transit_gateway_peering_attachment_accepter.this_ten_to_this_three.id
        from          = local.ten_tgw.full_name
        to            = local.three_tgw.full_name
      }
      four = {
        attachment_id = aws_ec2_transit_gateway_peering_attachment_accepter.this_ten_to_this_four.id
        from          = local.ten_tgw.full_name
        to            = local.four_tgw.full_name
      }
      five = {
        attachment_id = aws_ec2_transit_gateway_peering_attachment_accepter.this_ten_to_this_five.id
        from          = local.ten_tgw.full_name
        to            = local.five_tgw.full_name
      }
      six = {
        attachment_id = aws_ec2_transit_gateway_peering_attachment_accepter.this_ten_to_this_six.id
        from          = local.ten_tgw.full_name
        to            = local.six_tgw.full_name
      }
      seven = {
        attachment_id = aws_ec2_transit_gateway_peering_attachment_accepter.this_ten_to_this_seven.id
        from          = local.ten_tgw.full_name
        to            = local.seven_tgw.full_name
      }
      eight = {
        attachment_id = aws_ec2_transit_gateway_peering_attachment_accepter.this_ten_to_this_eight.id
        from          = local.ten_tgw.full_name
        to            = local.eight_tgw.full_name
      }
      nine = {
        attachment_id = aws_ec2_transit_gateway_peering_attachment_accepter.this_ten_to_this_nine.id
        from          = local.ten_tgw.full_name
        to            = local.nine_tgw.full_name
      }
    }
  }
}

