defmodule Anna.Importer do
  import Ecto.Query
  alias Anna.Repo

  @percent_checks 0.3
  @percent_cash_pre_covid 0.2
  @percent_cash_during_covid 0.05
  @percent_cash_post_covid 0.1
  @average_cash_amount_compared_check 0.3

  def run do
    account_id = build_account()

    %{account_id: account_id, build_new_campuses: false}
    |> build_funds()
    |> scrub_funds()
    |> find_campus_funds()
    |> build_donations()
    |> build_txn_counts()
    # |> build_checks()
    |> build_cash()
  end

  def start_over do
    Repo.delete_all(Anna.Txn)
    Repo.delete_all(Anna.GivingUnit)
    Repo.delete_all(Anna.Fund)
    Repo.delete_all(Anna.Campus)
  end

  def build_checks(
        params = %{
          account_id: account_id,
          campus_fund_outside_ids: campus_fund_outside_ids,
          day_rows: day_rows
        }
      ) do
    day_rows
    # |> Enum.take(1)
    |> Enum.map(fn row ->
      build_check_row(params, row)
    end)

    params
  end

  def build_check_row(params, [online_count, 0, _, date]) do
    checks_to_make = ceil(online_count * @percent_checks)

    params = Map.put(params, :date, date)

    Enum.each(0..checks_to_make, fn _ ->
      create_check_txn(params)
    end)
  end

  def build_check_row(_, _) do
    :noop
  end

  def create_check_txn(params = %{date: date, account_id: account_id}) do
    check_values = get_random_check_values(account_id)

    giving_unit =
      case :rand.uniform(10) do
        x when x < 3 ->
          create_giving_unit(check_values.campus_id, account_id)

        _ ->
          choose_random_giver(check_values.campus_id, account_id)
      end

    [datetime, date, month] = make_dates(date)

    vals =
      Map.from_struct(check_values)
      |> Map.put(:payment_type, "check")
      |> Map.put(:giving_unit_id, giving_unit.id)
      |> Map.put(:date, date)
      |> Map.put(:month, month)
      |> Map.put(:datetime, datetime)
      |> Map.put(:source, "check")
      |> Map.put(:age_of_giver, giving_unit.age)
      |> Map.put(:zipcode, giving_unit.zipcode)

    Ecto.Changeset.cast(%Anna.Txn{}, vals, [
      :age_of_giver,
      :amount_cents,
      :payment_type,
      :source,
      :zipcode,
      :giving_unit_id,
      :campus_id,
      :account_id,
      :datetime,
      :date,
      :month
    ])
    |> Repo.insert!()
  end

  def build_cash(
        params = %{
          account_id: account_id,
          campus_fund_outside_ids: campus_fund_outside_ids,
          day_rows: day_rows
        }
      ) do
    day_rows
    # |> Enum.take(1)
    |> Enum.map(fn row ->
      build_cash_row(params, row)
    end)

    params
  end

  def build_cash_row(params, [online_count, _, 0, date]) do
    percent_cash_by_volume =
      cond do
        Timex.compare(~D[2020-04-01], date) == 1 -> @percent_cash_pre_covid
        Timex.compare(~D[2020-08-01], date) == 1 -> @percent_cash_during_covid
        true -> @percent_cash_post_covid
      end
      |> IO.inspect(label: :by_volume)

    IO.inspect(date, label: :date)

    percent_cashs =
      (percent_cash_by_volume / @average_cash_amount_compared_check)
      |> IO.inspect(label: :percents_cash)

    IO.inspect(online_count, label: :online_count)

    cashs_to_make = ceil(online_count * percent_cashs) |> IO.inspect(label: :cashs_to_make)

    params = Map.put(params, :date, date)

    Enum.each(0..cashs_to_make, fn _ ->
      create_cash_txn(params)
    end)
  end

  def build_cash_row(_, _) do
    :noop
  end

  def create_cash_txn(params = %{date: date, account_id: account_id}) do
    cash_values = get_random_cash_values(account_id)

    giving_unit =
      case :rand.uniform(10) do
        x when x < 3 ->
          create_giving_unit(cash_values.campus_id, account_id)

        x when x < 5 ->
          choose_random_giver(cash_values.campus_id, account_id)

        _ ->
          choose_random_cash_giver(cash_values.campus_id, account_id)
      end

    [datetime, date, month] = make_dates(date)

    vals =
      Map.from_struct(cash_values)
      |> Map.put(:payment_type, "cash")
      |> Map.put(:giving_unit_id, giving_unit.id)
      |> Map.put(:date, date)
      |> Map.put(:month, month)
      |> Map.put(:datetime, datetime)
      |> Map.put(:source, "cash")
      |> Map.put(:age_of_giver, giving_unit.age)
      |> Map.put(:zipcode, giving_unit.zipcode)

    Ecto.Changeset.cast(%Anna.Txn{}, vals, [
      :age_of_giver,
      :amount_cents,
      :payment_type,
      :source,
      :zipcode,
      :giving_unit_id,
      :campus_id,
      :account_id,
      :datetime,
      :date,
      :month
    ])
    |> Repo.insert!()
  end

  def build_txn_counts(params) do
    sql = """
    select
    count(*) as total,
    sum(case when payment_type = 'check' then 1 else 0 end) as check,
    sum(case when payment_type = 'cash' then 1 else 0 end) as cash,
    t.date
    from transactions t
    where t.source != 'recurring'
    group by t.date
    order by 4 desc
    """

    %{rows: day_rows} = Ecto.Adapters.SQL.query!(Repo, sql)

    donation_count = from(txn in Anna.Txn, select: count(txn.id)) |> Repo.one()

    params
    |> Map.put(:donation_count, donation_count)
    |> Map.put(:day_rows, day_rows)
  end

  def find_campus_funds(params = %{account_id: account_id}) do
    campus_fund_outside_ids =
      from(f in Anna.Fund,
        where: not is_nil(f.campus_id),
        where: f.account_id == ^account_id,
        select: f.outside_id
      )
      |> Repo.all()

    Map.put(params, :campus_fund_outside_ids, campus_fund_outside_ids)
  end

  def build_donations(
        params = %{account_id: account_id, campus_fund_outside_ids: campus_fund_outside_ids}
      ) do
    from(d in Sd.Donation,
      join: cus in Sd.Customer,
      on: cus.id == d.customer_id,
      left_join: f in Sd.Fund,
      on: f.id == d.fund_id,
      where: d.account_id == 219,
      where: d.created_at < ago(239, "day"),
      where: d.created_at > ago(759, "day"),
      limit: 1,
      order_by: [desc: d.id],
      select: {cus, d}
    )
    |> Anna.ReadOnlyRepo.all()
    |> Enum.map(fn {cus, d} ->
      Repo.get_by(Anna.Txn, %{outside_id: d.id})
      |> case do
        nil ->
          campus_id = find_campus_id(cus, campus_fund_outside_ids)

          giving_unit =
            find_or_create_giving_unit(%{cus: cus, campus_id: campus_id, account_id: account_id})

          payment_type = if d.payment_type == "card", do: "card", else: "ach"
          d.created_at |> IO.inspect()
          [datetime, date, month] = get_dates(d) |> IO.inspect()

          fund_id =
            if d.fund_id do
              Repo.get_by(Anna.Fund, %{outside_id: d.fund_id})
              |> case do
                nil ->
                  nil

                found ->
                  found.id
              end
            else
              nil
            end

          source = d.donation_type || "web"

          %Anna.Txn{
            age_of_giver: giving_unit.age,
            amount_cents: d.gross_amount,
            payment_type: payment_type,
            source: source,
            zipcode: giving_unit.zipcode,
            giving_unit_id: giving_unit.id,
            campus_id: giving_unit.campus_id,
            fund_id: fund_id,
            account_id: account_id,
            outside_id: d.id,
            datetime: datetime,
            date: date,
            month: month
          }
          |> Repo.insert!()

        found ->
          found
      end
    end)

    params
  end

  def find_or_create_giving_unit(%{cus: cus, campus_id: campus_id, account_id: account_id}) do
    Repo.get_by(Anna.GivingUnit, %{outside_id: cus.id})
    |> case do
      nil ->
        Ecto.Changeset.change(generate_giving_unit(account_id), %{
          campus_id: campus_id,
          outside_id: cus.id
        })
        |> Repo.insert!()

      found ->
        found
    end
  end

  def create_giving_unit(campus_id, account_id) do
    Ecto.Changeset.change(generate_giving_unit(account_id), %{campus_id: campus_id})
    |> Repo.insert!()
  end

  def generate_giving_unit(account_id) do
    name = [Faker.Person.first_name(), Faker.Person.last_name()] |> Enum.join(" ")
    age = random_age()
    age_band = find_age_band(age)
    zipcode = Enum.shuffle(zipcodes) |> List.first()

    %Anna.GivingUnit{
      name: name,
      age: age,
      age_band: age_band,
      account_id: account_id,
      zipcode: zipcode
    }
  end

  def build_account do
    account =
      Repo.get_by(Anna.Account, %{outside_id: 219})
      |> case do
        nil ->
          %Anna.Account{outside_id: 219, name: "Zillside Church"}
          |> Anna.Repo.insert!()

        found ->
          found
      end

    account.id
  end

  def build_funds(params = %{account_id: account_id}) do
    from(f in Sd.Fund,
      where: f.account_id == 219
    )
    |> Anna.ReadOnlyRepo.all()
    |> Enum.map(fn fund ->
      Repo.get_by(Anna.Fund, %{outside_id: fund.id})
      |> case do
        nil ->
          %Anna.Fund{outside_id: fund.id, name: fund.name, account_id: account_id}
          |> Anna.Repo.insert!()

        _ ->
          :noop
      end
    end)

    params
  end

  def scrub_funds(params = %{build_new_campuses: false}) do
    params
  end

  def scrub_funds(params) do
    campus_dictionary =
      from(f in Anna.Fund)
      |> Repo.all()
      |> Enum.filter(fn fund ->
        String.split(fund.name, " - ")
        |> case do
          [_] ->
            false

          _ ->
            true
        end
      end)
      |> Enum.map(fn fund ->
        [campus_name, _] = String.split(fund.name, " - ")

        campus_name
      end)
      |> Enum.uniq()
      |> Enum.map(fn name ->
        new_campus_name = Faker.Address.city()
        {name, new_campus_name}
      end)
      |> Enum.into(%{})

    from(f in Anna.Fund)
    |> Repo.all()
    |> Enum.filter(fn fund ->
      String.split(fund.name, " - ")
      |> case do
        [_] ->
          false

        _ ->
          true
      end
    end)
    |> Enum.map(fn fund ->
      [campus_name, fund_name] = String.split(fund.name, " - ")

      new_campus_name = campus_dictionary[campus_name]

      campus =
        Repo.get_by(Anna.Campus, %{name: new_campus_name})
        |> case do
          nil ->
            %Anna.Campus{name: new_campus_name, account_id: 1}
            |> Anna.Repo.insert!()

          found ->
            found
        end

      Ecto.Changeset.change(fund, %{campus_id: campus.id}) |> Repo.update!()

      new_fund_name = [campus.name, fund_name] |> Enum.join(" - ")
      Ecto.Changeset.change(fund, %{name: new_fund_name}) |> Repo.update!()
    end)

    params
  end

  def random_age do
    [Statistics.Distributions.Normal.rand(50, 15), 15]
    |> Enum.max()
    |> round()
  end

  def find_age_band(age) do
    case age do
      x when x < 21 ->
        "10 - 20"

      x when x < 31 ->
        "21 - 30"

      x when x < 41 ->
        "31 - 40"

      x when x < 51 ->
        "41 - 50"

      x when x < 61 ->
        "51 - 60"

      x when x < 71 ->
        "61 - 70"

      _ ->
        "70+"
    end
  end

  def find_campus_id(cus, campus_fund_outside_ids) do
    from(d in Sd.Donation,
      where: d.fund_id in ^campus_fund_outside_ids,
      where: d.customer_id == ^cus.id,
      limit: 1,
      order_by: [desc: :id],
      select: d.fund_id
    )
    |> Anna.ReadOnlyRepo.one()
    |> case do
      nil ->
        nil

      outside_fund_id ->
        anna_fund = Repo.get_by(Anna.Fund, %{outside_id: outside_fund_id})
        anna_fund.campus_id
    end
  end

  def get_random_check_values(account_id) do
    from(txn in Anna.Txn,
      where: txn.account_id == ^account_id,
      where: txn.payment_type in ["check", "ach"],
      order_by: fragment("RANDOM()"),
      limit: 1
    )
    |> Repo.one()
  end

  def get_random_cash_values(account_id) do
    txn = get_random_check_values(account_id)

    amount_cents =
      ceil(ceil(txn.amount_cents * @average_cash_amount_compared_check) / 1000) * 1000

    Map.put(txn, :amount_cents, amount_cents)
  end

  def choose_random_giver(nil, account_id) do
    from(gu in Anna.GivingUnit,
      where: gu.account_id == ^account_id,
      order_by: fragment("RANDOM()"),
      limit: 1
    )
    |> Repo.one()
  end

  def choose_random_giver(campus_id, account_id) do
    from(gu in Anna.GivingUnit,
      where: gu.campus_id == ^campus_id,
      where: gu.account_id == ^account_id,
      order_by: fragment("RANDOM()"),
      limit: 1
    )
    |> Repo.one()
  end

  def choose_random_cash_giver(nil, account_id) do
    from(gu in Anna.GivingUnit,
      where: gu.account_id == ^account_id,
      join: txn in Anna.Txn,
      where: txn.payment_type == "cash",
      order_by: fragment("RANDOM()"),
      limit: 1
    )
    |> Repo.one()
    |> case do
      nil ->
        choose_random_giver(nil, account_id)

      found ->
        found
    end
  end

  def choose_random_cash_giver(campus_id, account_id) do
    from(gu in Anna.GivingUnit,
      join: txn in Anna.Txn,
      where: txn.payment_type == "cash",
      where: gu.campus_id == ^campus_id,
      where: gu.account_id == ^account_id,
      order_by: fragment("RANDOM()"),
      limit: 1
    )
    |> Repo.one()
    |> case do
      nil ->
        choose_random_giver(campus_id, account_id)

      found ->
        found
    end
  end

  def get_dates(donation) do
    datetime_utc = DateTime.from_naive!(donation.created_at, "Etc/UTC")
    timezone = Timex.Timezone.get("America/New_York", Timex.now())
    # offset = Timex.Timezone.diff(Timex.now(), timezone) * -1
    # Timex.shift(copy_at, seconds: offset)

    datetime = datetime_utc |> Timex.Timezone.convert(timezone)
    date = Timex.to_date(datetime)
    month = Timex.beginning_of_month(datetime) |> Timex.to_date()
    datetime = Timex.Timezone.convert(datetime, "Etc/UTC")
    [datetime, date, month]
  end

  def make_dates(date) do
    datetime =
      NaiveDateTime.from_erl!({Date.to_erl(date), {12, 0, 0}}) |> DateTime.from_naive!("Etc/UTC")

    month = Timex.beginning_of_month(date)
    [datetime, date, month]
  end

  def zipcodes do
    [
      64001,
      64011,
      64012,
      64001,
      64011,
      64012,
      64001,
      64011,
      64012,
      64014,
      64015,
      64001,
      64011,
      64012,
      64014,
      64015,
      64001,
      64011,
      64012,
      64014,
      64015,
      64016,
      64017,
      64018,
      64020,
      64021,
      64022,
      64001,
      64011,
      64012,
      64014,
      64015,
      64016,
      64017,
      64018,
      64020,
      64021,
      64022,
      64001,
      64011,
      64012,
      64014,
      64015,
      64016,
      64017,
      64018,
      64020,
      64021,
      64022,
      64024,
      64029,
      64030,
      64034,
      64035,
      64036,
      64037,
      64048,
      64050,
      64052,
      64053,
      64054,
      64055,
      64001,
      64011,
      64012,
      64014,
      64015,
      64016,
      64017,
      64018,
      64020,
      64021,
      64022,
      64024,
      64029,
      64030,
      64034,
      64035,
      64036,
      64037,
      64048,
      64050,
      64052,
      64053,
      64054,
      64055,
      64001,
      64011,
      64012,
      64014,
      64015,
      64016,
      64017,
      64018,
      64020,
      64021,
      64022,
      64024,
      64029,
      64030,
      64034,
      64035,
      64036,
      64037,
      64048,
      64050,
      64052,
      64053,
      64054,
      64055,
      64056,
      64057,
      64058,
      64060,
      64062,
      64063,
      64064,
      64065,
      64066,
      64067,
      64068,
      64070,
      64071,
      64072,
      64074,
      64075,
      64076,
      64077,
      64078,
      64079,
      64080,
      64081,
      64082,
      64083,
      64084,
      64085,
      64086,
      64088,
      64089,
      64090,
      64092,
      64096,
      64097,
      64098,
      64101,
      64102,
      64105,
      64106,
      64108,
      64109,
      64110,
      64111,
      64112,
      64113,
      64114,
      64116,
      64117,
      64118,
      64119,
      64120,
      64123,
      64124,
      64125,
      64126,
      64127,
      64128,
      64129,
      64130,
      64131,
      64132,
      64133,
      64134,
      64136,
      64137,
      64138,
      64139,
      64145,
      64146,
      64147,
      64149,
      64150,
      64151,
      64152,
      64153,
      64154,
      64155,
      64156,
      64157,
      64158,
      64161,
      64163,
      64164,
      64165,
      64166,
      64167,
      64192,
      64429,
      64439,
      64444,
      64454,
      64465,
      64477,
      64492,
      64493,
      64624,
      64625,
      64637,
      64644,
      64649,
      64650,
      64671,
      64701,
      64720,
      64722,
      64723,
      64725,
      64730,
      64734,
      64742,
      64743,
      64745,
      64746,
      64747,
      64752,
      64779,
      64780,
      65327
    ]
  end
end
